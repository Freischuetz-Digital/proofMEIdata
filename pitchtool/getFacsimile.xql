(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Daniel Röwenstrunk 2012.
: kepper(at)edirom.de & roewenstrunk(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This file returns an image scr-path
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

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $path := request:get-parameter('path', '')
let $staffN := request:get-parameter('staff', '')

let $doc := doc('/db/apps/pitchtool-data/' || $path)
let $zones := for $staff in $doc//mei:staff[@n = $staffN]
              return $doc/id($staff/substring-after(@facs,'#'))
              
let $surface := $doc//mei:surface[1]
let $graphic := $surface/mei:graphic[1]

let $top := min($zones/number(@uly))
let $left := min($zones/number(@ulx))
let $right := max($zones/number(@lrx))
let $bottom := max($zones/number(@lry))

let $margin := ($bottom - $top) div 15
let $top := max(($top - $margin, 0))
let $bottom := min(($bottom + $margin, number($graphic/@height)))

let $path := $graphic/@target
let $pageN := $surface/@n

let $dw := 1200
let $wx := $left div number($graphic/@width)
let $wy := $top div number($graphic/@height)
let $ww := ($right - $left) div number($graphic/@width)
let $wh := ($bottom - $top) div number($graphic/@height)

let $imgSrc := concat('/digilib/Scaler/freidi/',$path,'?dw=',$dw,'&amp;amp;wx=',$wx,'&amp;amp;wy=',$wy,'&amp;amp;ww=',$ww,'&amp;amp;wh=',$wh)

return
    $imgSrc