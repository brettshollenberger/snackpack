angular
  .module('snackpack')
  .directive('apiRequestExample', [function() {
    return {
      scope: {},
      templateUrl: "directives/api-request-example.html",
      link: function(scope, element, attrs) {
        var method      = attrs.method,
            url         = attrs.url,
            exampleData = attrs.exampleData,
            $codeblock  = element.find(".api-response").find("code");

        scope.exampleData     = exampleData;
        scope.noData          = !_.isUndefined(attrs.noData);
        scope.createsDelivery = !_.isUndefined(attrs.createsDelivery);
        scope.quickstart      = !_.isUndefined(attrs.quickstart);

        function replacer(match, pIndent, pKey, pVal, pEnd) {
          var key = '<span class="json-key">';
          var val = '<span class="json-value">';
          var str = '<span class="json-string">';
          var r = pIndent || '';
          if (pKey)
            r = r + key + pKey.replace(/[": ]/g, '') + '</span>: ';
          if (pVal)
            r = r + (pVal[0] == '"' ? str : val) + pVal + '</span>';
          return r + (pEnd || '');
        }

        function prettyPrint(obj) {
          var jsonLine = /^( *)("[\w]+": )?("[^"]*"|[\w.+-]*)?([,[{])?$/mg;

          return JSON.stringify(obj, null, 3)
            .replace(/&/g, '&amp;').replace(/\\"/g, '&quot;')
            .replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(jsonLine, replacer);
        }

        element.find(".submit").on("click", function() {
          var data = {};

          if (!_.isEmpty(scope.exampleData)) {
            try {
              data = JSON.parse(scope.exampleData);
            } catch(e) {}
          }

          if (url.match(/\:\w+/)) {
            reqUrl = url.replace(/\:\w+/, function(param) {
              param = param.slice(1);
              var result = _.isUndefined(data[param]) ? ":" + param : data[param];
              delete data[param];
              return result;
            });
          } else {
            reqUrl = url;
          }

          if (reqUrl.match(/\:\w+/)) {
            $codeblock.html("You're missing required parameters.");
            return;
          }

          $.ajaxAsObservable({
            method: method,
            url: reqUrl,
            data: data
          }).subscribe(
          function(response) {
            $codeblock.html(prettyPrint({
              status: response.jqXHR.status,
              body: response.data
            }));
          },
          function(error) {
            $codeblock.html(prettyPrint({
              status: error.jqXHR.status,
              body: error.jqXHR.responseJSON
            }));
          });
        });
      }
    }
  }]);
