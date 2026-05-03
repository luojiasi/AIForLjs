import 'package:flutter/material.dart';
import 'models.dart';
import 'INOVANCE/paramsdetails/sv630c_params.dart' as p630c;
import 'INOVANCE/paramsdetails/sv630n_params.dart' as p630n;
import 'INOVANCE/paramsdetails/sv630p_params.dart' as p630p;
import 'INOVANCE/paramsdetails/sv660a_params.dart' as p660a;
import 'INOVANCE/paramsdetails/sv660c_params.dart' as p660c;
import 'INOVANCE/paramsdetails/sv660f_params.dart' as p660f;
import 'INOVANCE/paramsdetails/sv660p_params.dart' as p660p;
import 'INOVANCE/handleproblems/sv630c_faults.dart' as f630c;
import 'INOVANCE/handleproblems/sv630n_faults.dart' as f630n;
import 'INOVANCE/handleproblems/sv630p_faults.dart' as f630p;
import 'INOVANCE/handleproblems/sv660a_faults.dart' as f660a;
import 'INOVANCE/handleproblems/sv660c_faults.dart' as f660c;
import 'INOVANCE/handleproblems/sv660f_faults.dart' as f660f;
import 'INOVANCE/handleproblems/sv660p_faults.dart' as f660p;
import 'JMC/paramsdetails/jand4002_params.dart' as pJand;
import 'JMC/handleproblems/jand4002_faults.dart' as fJand;

class BrandDevicePage extends StatelessWidget {
  final String brand;
  final String device;

  const BrandDevicePage({super.key, required this.brand, required this.device});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$brand $device'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '参数说明', icon: Icon(Icons.list_alt)),
              Tab(text: '故障处理', icon: Icon(Icons.warning_amber)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ParamList(device: device),
            _FaultList(device: device),
          ],
        ),
      ),
    );
  }
}

class _ParamList extends StatelessWidget {
  final String device;
  const _ParamList({required this.device});

  List<DeviceParam> get _params {
    switch (device) {
      case 'SV630C': return p630c.sv630cParams;
      case 'SV630N': return p630n.sv630nParams;
      case 'SV630P': return p630p.sv630pParams;
      case 'SV660A': return p660a.sv660aParams;
      case 'SV660C': return p660c.sv660cParams;
      case 'SV660F': return p660f.sv660fParams;
      case 'SV660P': return p660p.sv660pParams;
      case 'JAND4002': return pJand.jand4002Params;
      default: return p660a.sv660aParams;
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = _params;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: params.length,
      itemBuilder: (context, index) {
        final p = params[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: ListTile(
            dense: true,
            title: Text('${p.code}  ${p.name}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: p.addr.isNotEmpty
                ? Text('地址: ${p.addr}', style: const TextStyle(fontSize: 12))
                : null,
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => _showParamDetail(context, p),
          ),
        );
      },
    );
  }

  void _showParamDetail(BuildContext context, DeviceParam p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('${p.code}  ${p.name}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                if (p.addr.isNotEmpty) _detailRow('通信地址', p.addr),
                if (p.effect.isNotEmpty) _detailRow('生效方式', p.effect),
                if (p.min.isNotEmpty) _detailRow('最小值', p.min),
                if (p.max.isNotEmpty) _detailRow('最大值', p.max),
                if (p.unit.isNotEmpty) _detailRow('单位', p.unit),
                if (p.dtype.isNotEmpty) _detailRow('数据类型', p.dtype),
                if (p.defaultVal.isNotEmpty) _detailRow('默认值', p.defaultVal),
                if (p.change.isNotEmpty) _detailRow('更改方式', p.change),
                if (p.range.isNotEmpty) _detailRow('范围', p.range),
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('参数说明',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  const SizedBox(height: 8),
                  SelectableText(p.description,
                      style: const TextStyle(fontSize: 14, height: 1.6)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey)),
          ),
          Expanded(
            child: SelectableText(value,
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _FaultList extends StatelessWidget {
  final String device;
  const _FaultList({required this.device});

  List<DeviceFault> get _faults {
    switch (device) {
      case 'SV630C': return f630c.sv630cFaults;
      case 'SV630N': return f630n.sv630nFaults;
      case 'SV630P': return f630p.sv630pFaults;
      case 'SV660A': return f660a.sv660aFaults;
      case 'SV660C': return f660c.sv660cFaults;
      case 'SV660F': return f660f.sv660fFaults;
      case 'SV660P': return f660p.sv660pFaults;
      case 'JAND4002': return fJand.jand4002Faults;
      default: return f660a.sv660aFaults;
    }
  }

  @override
  Widget build(BuildContext context) {
    final faults = _faults;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: faults.length,
      itemBuilder: (context, index) {
        final f = faults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: ListTile(
            dense: true,
            title: Text('${f.code}  ${f.name}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => _showFaultDetail(context, f),
          ),
        );
      },
    );
  }

  void _showFaultDetail(BuildContext context, DeviceFault f) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(f.code,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red[700], fontSize: 14)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(),
                if (f.mechanism.isNotEmpty) ...[
                  const Text('故障机理',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  const SizedBox(height: 8),
                  SelectableText(f.mechanism,
                      style: const TextStyle(fontSize: 14, height: 1.6)),
                  const SizedBox(height: 16),
                ],
                if (f.troubleshoot.isNotEmpty) ...[
                  const Text('故障排除',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFFE65100)
                        )
                      ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child:
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            f.troubleshoot,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.deepOrangeAccent
                            ),
                          ),
                        ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
