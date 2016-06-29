/*
 * Renders a tree diagram for a scenario
 *
 * Embed as: <scenario-tree tree-width="50px" tree-height="50px" scenario-id="1"></scenario-tree>
 * Publish "scenario:update" to have it redraw()
 * Emits "scenario:tree:node-selected" when node is clicked.
 */
alchemy.directive('reportingTree', ['ScenarioApiClient', 'Util', function(ScenarioApiClient, Util) {

  var defaultFor = function(arg, val) {
    return typeof arg !== 'undefined' ? arg : val;
  };

  var edgeHoverTemplate = function(body) {
    if(!body) return null;
    var text = "<div class='edge-popup'>";
    text += "<p>" + breakText(40, body) + "</p>";
    text += "</div>";
    return text;
  };

  var nextWhitespaceFrom = function(index, str) {
    var whitespaceTest = /\s/;
    if(!whitespaceTest.test(str)) {
      return -1;
    }

    var spaceLocation = str.indexOf(" ", index);
    if(spaceLocation != -1) {
      return spaceLocation;
    } else {
      return str.indexOf("\t", index);
    }
  };

  var breakText = function(width, str) {
    if(!str) return null;

    var index = width;

    while(index < str.length) {
      var nextWhitespace = nextWhitespaceFrom(index, str);
      if(nextWhitespace != -1) {
        str = str.slice(0, nextWhitespace) + "<br>" + str.slice(nextWhitespace);
        index = Math.max(nextWhitespace + 1, index + width);
      } else {
        break;
      }
    }

    return str;
  };

  return {
    restrict: 'E',
    scope: {
      choices: "=",
      decisions: "=",
      nodes: "="
    },
    templateUrl: 'reporting/_reporting_tree.html',
    replace: true,
    link: function(scope, element, attrs) {
      var display = element[0];

      var options = {
        width: defaultFor(attrs.treeWidth, '100%'),
        height: defaultFor(attrs.treeHeight, '100%'),
        smoothCurves: true,
        stabilize: true,
        selectable: false,
        nodes: {
          radius: 10,
          fontColor: "white",
          fontSize: "16"
        },
        edges: {
          color: "black",
          style: "arrow",
          arrowScaleFactor: 0.3,
          labelAlignment: "line-above"
        },
        tooltip: {
          delay: 50,
          fontColor: "black",
          fontSize: 12, // px
          fontFace: "arial",
          color: {
            border: "#666",
            background: "#FFFFC6"
          }
        },
        hierarchicalLayout: {
          layout: "direction",
          direction: "UD"
        }
      };

      display.style.width = options.width;
      display.style.height = options.height;

      var draw = function() {
        if(!scope.choices) return;
        var edges = _.map(scope.choices, _.clone);
        var nodes = _.map(scope.nodes, _.clone);

        if(scope.decisions) {
          var decisionsCopy = _.map(scope.decisions, _.clone);
          edges = edges.concat(decisionsCopy);
        }

        _.each(nodes, function(node) {
          node.title = Util.nodeHoverTemplate(node.title, node.body);
        });

        _.each(edges, function(edge) {
          edge.title = edgeHoverTemplate(edge.title);
        });

        var data = {
          nodes: nodes,
          edges: edges,
          options: options
        };

        var network = new vis.Network(display, data, options);
      };

      scope.$watch('choices', function(newVal, oldVal) {
        draw();
      });
    }
  };
}]);
