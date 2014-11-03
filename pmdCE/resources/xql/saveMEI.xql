xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

(:import module namespace functx="http://www.functx.com";:)

import module namespace functx="http://www.functx.com" at "/db/apps/EdiromOnline/data/xqm/functx-1.0-nodoc-2007-01.xq";


declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes";

let $xml := request:get-data()
let $staffN := request:get-parameter('staffN', '')
let $path := request:get-parameter('path', '')
(:let $user := xmldb:get-current-user()
let $doc := transform:transform($xml, doc('mergeWithPage.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="pageFilePath" value="/db/apps/controlevents-data/{$path}"/><param name="resp" value="{$user}"/></parameters>)
let $result := xmldb:store(concat('/db/apps/controlevents-data/', functx:substring-before-last($path, '/')), functx:substring-after-last($path, '/'), $doc)
:)return
    ''
    
