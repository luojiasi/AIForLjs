import 'overview/overview_detail.dart';
import 'architecture/architecture_detail.dart';
import 'token_mgmt/token_mgmt_detail.dart';
import 'adapter_pattern/adapter_pattern_detail.dart';
import 'rate_limiting/rate_limiting_detail.dart';
import 'security/security_detail.dart';
import 'deployment/deployment_detail.dart';
import 'api_reference/api_reference_detail.dart';

const Map<String, String> topicFullDetails = {
  'overview': overviewFullDetail,
  'architecture': architectureFullDetail,
  'token_mgmt': tokenMgmtFullDetail,
  'adapter_pattern': adapterPatternFullDetail,
  'rate_limiting': rateLimitingFullDetail,
  'security': securityFullDetail,
  'deployment': deploymentFullDetail,
  'api_reference': apiReferenceFullDetail,
};
