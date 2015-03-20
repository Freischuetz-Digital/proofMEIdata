xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";


declare function local:getMdivs($source as xs:string) as xs:string* {
    let $mdivs := xmldb:get-child-collections('/db/apps/controlevents-data/' || $source)
    return
        for $mdiv in $mdivs
        order by $mdiv
        return
            '{"id": "' || $mdiv || '",' ||
            '"pages": [' || string-join(local:getPages($source, $mdiv), ',') || ']' ||
            '}'
};

declare function local:getPages($source as xs:string, $mdiv as xs:string) as xs:string* {
    let $pages := xmldb:get-child-resources('/db/apps/controlevents-data/' || $source || '/' || $mdiv)
    return
        for $page in $pages
        order by $page
        return
            '{"id": "' || substring-before($page, '.xml') || '",' ||
            '"path": "' || $source || '/' || $mdiv || '/' || $page || '"' ||
            '}'
};

declare function local:getSurfaces($source as xs:string, $mdiv as xs:string) as xs:string* {
    let $xml := doc('/db/apps/controlevents-data/' || $source || '/' || $mdiv)
    return
        for $surface in $xml//mei:surface
        return
            '{"id": "' || $surface/@xml:id || '",' ||
            '"n": "' || $surface/@n || '"' ||
            '}'
};

declare function local:getMovements($source as xs:string) as xs:string* {
    let $mdivs := xmldb:get-child-resources('/db/apps/controlevents-data/' || $source)
    return
        for $mdiv in $mdivs
        order by $mdiv
        return
            '{"id": "' || substring-before($mdiv, '.xml') || '",' ||
            '"pages": [' || string-join(local:getSurfaces($source, $mdiv), ',') || ']' ||
            '}'
};

let $sources := xmldb:get-child-collections('/db/apps/controlevents-data')
return
    '[' || 
    string-join(
        for $source in $sources
        return
            '{"sigle": "' || $source || '",' ||
            '"mdivs": [' || string-join(local:getMovements($source), ',') || ']' ||
            '}'
    , ',')
    || ']'
