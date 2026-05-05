/// Map from architecture ID to its full markdown detail content
import 'workflow_tool_calling/workflow_tool_calling_detail.dart';
import 'react/react_detail.dart';
import 'router_dispatcher/router_dispatcher_detail.dart';
import 'supervisor/supervisor_detail.dart';
import 'reflection/reflection_detail.dart';
import 'plan_execute/plan_execute_detail.dart';
import 'llm_compiler/llm_compiler_detail.dart';
import 'rewoo/rewoo_detail.dart';
import 'tree_of_thoughts/tree_of_thoughts_detail.dart';
import 'self_consistency/self_consistency_detail.dart';
import 'multi_agent_collaboration/multi_agent_collaboration_detail.dart';
import 'critic_editor/critic_editor_detail.dart';

const Map<String, String> architectureFullDetails = {
  'workflow_tool_calling': workflowToolCallingFullDetail,
  'react': reactFullDetail,
  'router_dispatcher': routerDispatcherFullDetail,
  'supervisor': supervisorFullDetail,
  'reflection': reflectionFullDetail,
  'plan_execute': planExecuteFullDetail,
  'llm_compiler': llmCompilerFullDetail,
  'rewoo': rewooFullDetail,
  'tree_of_thoughts': treeOfThoughtsFullDetail,
  'self_consistency': selfConsistencyFullDetail,
  'multi_agent_collaboration': multiAgentCollaborationFullDetail,
  'critic_editor': criticEditorFullDetail,
};
