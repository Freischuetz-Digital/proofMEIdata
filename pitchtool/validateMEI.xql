(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Daniel Röwenstrunk 2012.
: kepper(at)edirom.de & roewenstrunk(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This file triggers a validation of XML data in eXist-db
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

(:declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";


let $xml := request:get-data()
return
    (:transform:transform($xml, doc('/db/Website/resources/xslt/fastValidate.xsl'), ()):)
    validation:jing-report($xml, doc('freidi_pmd.rng'))
