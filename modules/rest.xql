xquery version "3.0";

module namespace freidi-rest="http://freischuetz-digital.de/freidi-tools/rest";

import module namespace config="http://freischuetz-digital.de/tools/config" at "config.xqm";

declare function freidi-rest:get($path) {
    let $option := util:declare-option("exist:serialize", "method=xml media-type=text/xml omit-xml-declaration=no indent=yes")
    let $id := request:get-parameter('id', '')
    let $resource := substring-after($path, '/rest/documents/')
    let $doc := doc(concat('/db/contents/', $resource))
    return if($id = '') then ($doc) else ($doc/id($id))
};

declare function freidi-rest:list($path) {
    let $accept := request:get-header('Accept')
    let $path := replace($path, '/rest/documents', '/db/contents')
    let $path := if(ends-with($path, '/'))then(substring($path, 1, string-length($path) - 1))else($path)
    return
        if(xmldb:collection-available($path))
        then (
            if(contains($accept, 'application/json'))
            then(util:declare-option("exist:serialize", "method=json media-type=application/json"))
            else(util:declare-option("exist:serialize", "method=xml media-type=text/xml omit-xml-declaration=no indent=yes"))
            ,
            <exist:result>
            {
                <exist:collection name="{$path}" created="{xmldb:created($path)}" owner="{xmldb:get-owner($path)}" group="{xmldb:get-group($path)}" permissions="{xmldb:permissions-to-string(xmldb:get-permissions($path))}">
                {
                    (
                        for $coll in xmldb:get-child-collections($path)
                        return freidi-rest:get-collection($path, $coll),
                        
                        for $resource in xmldb:get-child-resources($path)
                        return freidi-rest:get-resource($path, $resource)
                    )
                }    
                </exist:collection>
            }
            </exist:result>
        )
        else (freidi-rest:get($path))
};

declare function freidi-rest:get-collection($path, $coll) {
    <exist:collection name="{$coll}" created="{xmldb:created(concat($path, '/', $coll))}" owner="{xmldb:get-owner(concat($path, '/', $coll))}" group="{xmldb:get-group(concat($path, '/', $coll))}" permissions="{xmldb:permissions-to-string(xmldb:get-permissions(concat($path, '/', $coll)))}"/>
};

declare function freidi-rest:get-resource($path, $resource) {
    <exist:resource name="{$resource}" created="{xmldb:created($path, $resource)}" last-modified="{xmldb:last-modified($path, $resource)}" owner="{xmldb:get-owner($path)}" group="{xmldb:get-group($path)}" permissions="{xmldb:permissions-to-string(xmldb:get-permissions($path))}"/>
};

declare function freidi-rest:post($path) {
    let $id := request:get-parameter('id', '')
    let $resource := substring-after($path, '/rest/documents/')
    let $doc := doc(concat('/db/contents/', $resource))
    return  if($id = '') 
            then (
                if(xmldb:store('/db/contents', $resource, request:get-data()))
                then(<result>success</result>)
                else(<result>failure</result>)
            ) else (
                let $result := update replace $doc/id($id) with request:get-data()
                return <result>success</result>
            )
};

declare function freidi-rest:put($path, $resource) {
    let $path := replace($path, '/rest/documents', '/db/contents')
    return
        if(xmldb:store('/db/contents', $resource, request:get-data()))
        then(<result>success</result>)
        else(<result>failure</result>)
};