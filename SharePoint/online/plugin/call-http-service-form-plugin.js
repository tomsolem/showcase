// show how to do a http web request from a plugin

// Ensure that the SP javascript library is loaded
ctx = new SP.ClientContext(_spPageContextInfo.webServerRelativeUrl);

var getRequest = new SP.WebRequestInfo();
var externalUrl = "http://www.company.com/rest/getdata"
getRequest.set_url(externalUrl);
getRequest.set_method("GET");
var wpResponse = SP.WebProxy.invoke(ctx, getRequest);
ctx.executeQueryAsync(function() {
	if (wpResponse.get_statusCode() === 200) {
		var results = wpResponse.get_body();
		searchCache[term] = results;
		response(getOptions(searchCache[term]));
	}
});