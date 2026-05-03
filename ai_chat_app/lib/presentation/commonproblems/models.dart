class DeviceParam {
  final String code;
  final String name;
  final String addr;
  final String effect;
  final String min;
  final String max;
  final String unit;
  final String dtype;
  final String defaultVal;
  final String change;
  final String range;
  final String description;

  const DeviceParam({
    required this.code,
    required this.name,
    this.addr = '',
    this.effect = '',
    this.min = '',
    this.max = '',
    this.unit = '',
    this.dtype = '',
    this.defaultVal = '',
    this.change = '',
    this.range = '',
    this.description = '',
  });
}

class DeviceFault {
  final String code;
  final String name;
  final String mechanism;
  final String troubleshoot;

  const DeviceFault({
    required this.code,
    required this.name,
    this.mechanism = '',
    this.troubleshoot = '',
  });
}
