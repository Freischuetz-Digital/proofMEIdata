(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Daniel Röwenstrunk 2012.
: kepper(at)edirom.de & roewenstrunk(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This file stores a file to eXist-db
:
: This program is free software: you can redistribute it and/or modify
: it under the terms of the GNU General Public License as published by
: the Free Software Foundation, either version 3 of the License, or
: (at your option) any later version.
:
: This program is distributed in the hope that it will be useful,
: but WITHOUT ANY WARRANTY; without even the implied warranty of
: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
: GNU General Public License for more details.
:
: You should have received a copy of the GNU General Public License
: along with this program. If not, see <http://www.gnu.org/licenses/>.
:)

xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

(:import module namespace functx="http://www.functx.com";:)

import module namespace functx="http://www.functx.com" at "/db/apps/EdiromOnline/data/xqm/functx-1.0-nodoc-2007-01.xq";


declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes";

let $xml := request:get-data()
let $staffN := request:get-parameter('staffN', '')
let $path := request:get-parameter('path', '')
let $user := xmldb:get-current-user()
let $doc := transform:transform($xml, doc('mergeWithPage.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="pageFilePath" value="/db/apps/pitchtool-data/{$path}"/><param name="resp" value="{$user}"/></parameters>)
let $result := xmldb:store(concat('/db/apps/pitchtool-data/', functx:substring-before-last($path, '/')), functx:substring-after-last($path, '/'), $doc)
return
    $result
    
    (:return $doc:)
    
