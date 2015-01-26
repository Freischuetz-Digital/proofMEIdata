xquery version "3.0";

import module namespace freidi-rest="http://freischuetz-digital.de/freidi-tools/rest" at "modules/rest.xql";
import module namespace freidi-app="http://freischuetz-digital.de/freidi-tools/app" at "modules/app.xql";

declare namespace control="http://edirom.de/apps/freidi/controller";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare %private function control:match-path($input as xs:string, $template as xs:string) as xs:boolean {
    let $regex := "^" || replace($template, "\{\$([^\}]+)\}", "[^/]*") || "/?$"
    let $log := util:log("DEBUG", "$input: " || $input || " $template: " || $template || " $regex: " || $regex)
    return
        matches($input, $regex)
};

declare %private function control:get-path-variables($input as xs:string, $template as xs:string) as map(*)? {
    let $groupsRegex := "^" || replace($template, "\{\$([^\}]+)\}", "(.*)") || "$"
    let $groups := subsequence(text:groups($input, $groupsRegex), 2)
    let $analyzed := analyze-string($template, "\{\$[^\}]+\}")
    return
        map:new((
            map-pairs(function($group, $varExpr) {
                let $var := replace($varExpr, "\{\$([^\}]+)\}", "$1")
                return
                    map:entry($var, $group)
            }, $groups, $analyzed//fn:match)
        ))
};

declare %private function control:get-tools-root-path($path as xs:string) as xs:string {
    (:concat(substring-before($path, '/freidi-tools'), 'http://freischuetz-digital.de/freidi-tools'):)
    concat(substring-before($path, '/proofMEIdata'), '/proofMEIdata')
};



if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat(request:get-uri(), '/')}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>    
else if ($exist:path eq "/login/doLogin") then (
    util:declare-option("exist:serialize", "method=json media-type=application/json"),
    freidi-app:login()    
)
else if (xmldb:get-current-user() = "guest" and ends-with($exist:resource, ".html") and $exist:resource != 'login.html') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="login/login.html?path={encode-for-uri($exist:path)}"/>        
    </dispatch>

else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
(: REST GET :)
else if (matches($exist:path, "/rest/documents/.*\.xml") and request:get-method() = 'GET') then
    freidi-rest:get($exist:path)
else if (matches($exist:path, "/rest/documents.*") and request:get-method() = 'GET') then
    freidi-rest:list($exist:path)
else if (matches($exist:path, "/rest/documents/.*\.xml") and request:get-method() = 'POST') then
    freidi-rest:post($exist:path)    
else if (matches($exist:path, "/rest/documents/.*\.xml") and request:get-method() = 'PUT') then
    freidi-rest:put($exist:path, $exist:resource)    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>