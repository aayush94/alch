/*
 * Renders a tree diagram for a scenario
 *
 * Embed as: <scenario-tree tree-width="50px" tree-height="50px" scenario-id="1"></scenario-tree>
 * Publish "scenario:update" to have it redraw()
 * Emits "scenario:tree:node-selected" when node is clicked.
 */
alchemy.directive('scenarioTree', ['ScenarioApiClient', 'Util', function(ScenarioApiClient, Util) {

  var CURRENT_NODE_COLOR = "#fac32e";

  var defaultFor = function(arg, val) {
    return typeof arg !== 'undefined' ? arg : val;
  };

  var nodeIsSelected = function(selectEvent) {
    return selectEvent.nodes.length > 0;
  };

  var setCurrentNode = function(currentNodeId, nodes) {
    _.each(nodes, function(n) {
      if(n.id === currentNodeId) {
        n.color.border = CURRENT_NODE_COLOR;
      }
    });
  };

  return {
    restrict: 'E',
    scope: {},
    templateUrl: 'scenarios/tree/_tree.html',
    replace: true,
    link: function($scope, element, attrs) {

      var display = element[0];
      var scenarioId = attrs.scenarioId;
      var currentNodeId = parseInt(defaultFor(attrs.currentNodeId, 0));

      var options = {
        width: defaultFor(attrs.treeWidth, '100%'),
        height: defaultFor(attrs.treeHeight, '100%'),
        stabilize: true,
        smoothCurves: false,
        clustering: true,
        nodes: {
          fontFace: "Alchemy",
          radius: 30,
          fontColor: "white",
          fontSize: 16,
          borderWidth: 7,
          borderWidthSelected: 7
        },
        edges: {
          color: "black",
          style: "arrow"
        },
        hierarchicalLayout: {
          layout: "hubsize"
        }
      };

      display.style.width = options.width;
      display.style.height = options.height;

      var draw = function() {
        ScenarioApiClient.getTree(scenarioId).then(function(res) {

          setCurrentNode(currentNodeId, res.data.nodes);

          res.data.nodes = _.map(res.data.nodes, function(node) {
            node.title = Util.nodeHoverTemplate(node.title, node.body);
            return node;
          });

          var data = {
            nodes: res.data.nodes,
            edges: res.data.choices,
            options: options
          };

          var network = new vis.Network(display, data, options);

          network.on("select", function(params) {
            if(nodeIsSelected(params)) {
              $scope.$emit("scenario-tree:node-selected", params);
            }
          });

        });
      };

      //subscribe to generic tree event change
      $scope.$on("node:update", draw);

      draw();
    }
  };
}]);
