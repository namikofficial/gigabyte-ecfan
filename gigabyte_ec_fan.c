// SPDX-License-Identifier: GPL-2.0
/*
 * Gigabyte G5 MF5 EC fan tach (prototype)
 * Exposes fan1_input and GPU pwm1 via hwmon sysfs.
 */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/hwmon.h>
#include <linux/err.h>
#include <linux/dmi.h>
#include <linux/mutex.h>
#include <linux/acpi.h>   // ec_read()

#define EC_CPU_FAN_L 0xD1
#define EC_CPU_FAN_H 0xD3

#define EC_GPU_PWM_L 0xCE
#define EC_GPU_PWM_H 0xCF

struct gigabyte_ecfan_data {
    struct device *hwmon_dev;
    struct mutex lock;
};

static int read_period_u16(u16 *period)
{
    int ret;
    u8 l, h;

    ret = ec_read(EC_CPU_FAN_L, &l);
    if (ret) return ret;
    ret = ec_read(EC_CPU_FAN_H, &h);
    if (ret) return ret;

    *period = ((u16)l << 8) | h;
    return 0;
}

static long period_to_rpm(u16 period)
{
    if (!period) return 0;
    return (long)(1000000UL / period);
}

/* sysfs: fan1_input (CPU) */
static ssize_t fan1_input_show(struct device *dev,
                               struct device_attribute *attr,
                               char *buf)
{
    struct gigabyte_ecfan_data *data = dev_get_drvdata(dev);
    u16 period;
    int ret;
    long rpm;

    mutex_lock(&data->lock);
    ret = read_period_u16(&period);
    mutex_unlock(&data->lock);

    if (ret) return ret;

    rpm = period_to_rpm(period);
    return sysfs_emit(buf, "%ld\n", rpm);
}
static DEVICE_ATTR_RO(fan1_input);

/* sysfs: pwm1 (GPU) */
static ssize_t pwm1_show(struct device *dev,
                         struct device_attribute *attr,
                         char *buf)
{
    struct gigabyte_ecfan_data *data = dev_get_drvdata(dev);
    u8 l, h;
    int val;

    mutex_lock(&data->lock);
    if (ec_read(EC_GPU_PWM_L, &l) || ec_read(EC_GPU_PWM_H, &h)) {
        mutex_unlock(&data->lock);
        return -EIO;
    }
    mutex_unlock(&data->lock);

    val = ((l << 8) | h) * 255 / 65535;
    return sysfs_emit(buf, "%d\n", val);
}
static DEVICE_ATTR_RO(pwm1);

static struct attribute *gigabyte_ecfan_attrs[] = {
    &dev_attr_fan1_input.attr,
    &dev_attr_pwm1.attr,
    NULL
};

static const struct attribute_group gigabyte_ecfan_group = {
    .attrs = gigabyte_ecfan_attrs,
};

static const struct attribute_group *gigabyte_ecfan_groups[] = {
    &gigabyte_ecfan_group,
    NULL
};

static int gigabyte_ecfan_probe(struct platform_device *pdev)
{
    struct device *dev = &pdev->dev;
    struct gigabyte_ecfan_data *data;

    data = devm_kzalloc(dev, sizeof(*data), GFP_KERNEL);
    if (!data) return -ENOMEM;

    mutex_init(&data->lock);
    platform_set_drvdata(pdev, data);

    data->hwmon_dev = devm_hwmon_device_register_with_groups(
        dev, "gigabyte_ecfan", data, gigabyte_ecfan_groups);

    if (IS_ERR(data->hwmon_dev)) return PTR_ERR(data->hwmon_dev);

    return 0;
}

static struct platform_driver gigabyte_ecfan_driver = {
    .probe = gigabyte_ecfan_probe,
    .driver = {
        .name = "gigabyte_ecfan",
    },
};

static const struct dmi_system_id gigabyte_ecfan_dmi_table[] __initconst = {
    {
        .matches = {
            DMI_MATCH(DMI_SYS_VENDOR, "GIGABYTE"),
            DMI_MATCH(DMI_PRODUCT_NAME, "G5 MF5"),
        },
    },
    { }
};
MODULE_DEVICE_TABLE(dmi, gigabyte_ecfan_dmi_table);

static struct platform_device *gigabyte_ecfan_pdev;

static int __init gigabyte_ecfan_init(void)
{
    int ret;
    if (!dmi_check_system(gigabyte_ecfan_dmi_table)) return -ENODEV;

    ret = platform_driver_register(&gigabyte_ecfan_driver);
    if (ret) return ret;

    gigabyte_ecfan_pdev = platform_device_register_simple(
        "gigabyte_ecfan", -1, NULL, 0);

    if (IS_ERR(gigabyte_ecfan_pdev)) {
        ret = PTR_ERR(gigabyte_ecfan_pdev);
        platform_driver_unregister(&gigabyte_ecfan_driver);
        return ret;
    }

    return 0;
}

static void __exit gigabyte_ecfan_exit(void)
{
    platform_device_unregister(gigabyte_ecfan_pdev);
    platform_driver_unregister(&gigabyte_ecfan_driver);
}

module_init(gigabyte_ecfan_init);
module_exit(gigabyte_ecfan_exit);

MODULE_AUTHOR("Namik");
MODULE_DESCRIPTION("Gigabyte EC fan tach + GPU PWM hwmon");
MODULE_LICENSE("GPL");
