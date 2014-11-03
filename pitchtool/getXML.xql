(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Daniel Röwenstrunk 2012.
: kepper(at)edirom.de & roewenstrunk(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This file triggers a transformation with extractStaff.xsl and returns the result data
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

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes";

let $base := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/')

let $path := request:get-parameter('path', '')
let $staffN := request:get-parameter('staff', '')

let $doc := doc('/db/apps/pitchtool-data/' || $path)

return
    transform:transform($doc, doc($base || 'extractStaff.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="mode" value="ace"/></parameters>)