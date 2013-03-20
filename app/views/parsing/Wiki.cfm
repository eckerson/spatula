The wiki text parser supports wiki markup similar to the MediaWiki syntax, with only a few deviations.
It currently only supports the more commonly used formatting, and is not as fully featured as MediaWiki.

To tell the framework to use the wiki text parser for a page, set _variables.display_ to "wiki" in the controller.

== Formatting ==
Text formatting is done using normal characters such as asterisks, underscores, or equal signs.
The usage can vary depending on their position.
For example, to format a word in *bold*, you include it in two pairs of asterisks.
However, if you start a line with an asterisk, it will create a bullet list.

=== Text Markup ===
<table border="1" style="width: 100%; border-collapse: collapse;">
	<col span="3" width="33%" />
	<thead>
		<tr>
			<th>Description</th>
			<th>Markup</th>
			<th>Output</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th colspan="3">Inline Formatting</th>
		</tr>
		<tr>
			<td>Emphasis</td>
			<td>
				<pre>_Emphasis_</pre>
			</td>
			<td>_Emphasis_</td>
		</tr>
		<tr>
			<td>Strong</td>
			<td>
				<pre>*Strong*</pre>
			</td>
			<td>*Strong*</td>
		</tr>
		<tr>
			<td>Strong Emphasis</td>
			<td>
				<pre>_*Strong Emphasis*_</pre>
			</td>
			<td>_*Strong Emphasis*_</td>
		</tr>
	</tbody>
	<!--tbody>
		<tr>
			<th colspan="3">Preformatted</th>
		</tr>
		<tr>
			<td>Ignore Wiki markup</td>
			<td>
				<pre>&lt;nowiki>Markup is *ignored*&lt;/nowiki></pre>
			</td>
			<td><nowiki>Markup is *ignored*</nowiki></td>
		</tr>
	</tbody-->
	<tbody>
		<tr>
			<th colspan="3">Section formatting - only at the beginning of the line</th>
		</tr>
		<tr>
			<td>Headings of different levels</td>
			<td>
<pre>
== Heading 2 ==
=== Heading 3 ===
==== Heading 4 ====
===== Heading 5 =====
====== Heading 6 ======
</pre>
			</td>
			<td>
== Heading 2 ==
=== Heading 3 ===
==== Heading 4 ====
===== Heading 5 =====
====== Heading 6 ======
			</td>
		</tr>
		<tr>
			<td>Horizontal Rule</td>
			<td>
<pre>
Text above
----
Text below
</pre>
			</td>
			<td>
Text above
----
Text below
			</td>
		</tr>
		<tr>
			<td>Bullet List</td>
			<td>
<pre>
* Start each line
* with an asterisk (*).
** More asterisks gives deeper
*** and deeper levels.
* Line breaks&lt;br /&gt;don't break levels.
*** But jumping levels creates empty space.
Any other start ends the list.
</pre>
			</td>
			<td>
* Start each line
* with an asterisk (*).
** More asterisks gives deeper
*** and deeper levels.
* Line breaks<br />don't break levels.
*** But jumping levels creates empty space.
Any other start ends the list.
			</td>
		</tr>
		<tr>
			<td>Numbered List</td>
			<td>
<pre>
# Start each line
# with a number sign (#).
## More number signs gives deeper
### and deeper
### levels.
# Line breaks&lt;br /&gt;don't break levels.
### But jumping levels creates empty space.
# Blank lines

# end the list and start another.
Any other start also
ends the list.
</pre>
			</td>
			<td>
# Start each line
# with a number sign (#).
## More number signs gives deeper
### and deeper
### levels.
# Line breaks<br />don't break levels.
### But jumping levels creates empty space.
# Blank lines

# end the list and start another.
Any other start also
ends the list.
			</td>
		</tr>
		<tr>
			<td>Definition List</td>
			<td>
<pre>
;item 1
: definition 1
;item 2
: definition 2-1
: definition 2-2
</pre>
			</td>
			<td>
;item 1
: definition 1
;item 2
: definition 2-1
: definition 2-2
			</td>
		</tr>
		<tr>
			<td>Indent Text</td>
			<td>
<pre>
: Single indent
:: Double indent
::::: Multiple indent
</pre>
			</td>
			<td>
: Single indent
:: Double indent
::::: Multiple indent
			</td>
		</tr>
		<tr>
			<td>Mixture of different types of list</td>
			<td>
<pre>
# one
# two
#* two point one
#* two point two
# three
#; three item one
#: three def one
# four
#: four def one
#: this looks like a continuation
#: and is often used
#: instead&lt;br /&gt;of &lt;br /&gt;
# five
## five sub 1
### five sub 1 sub 1
## five sub 2
</pre>
			</td>
			<td>
# one
# two
#* two point one
#* two point two
# three
#; three item one
#: three def one
# four
#: four def one
#: this looks like a continuation
#: and is often used
#: instead<br />of &lt;br /&gt;
# five
## five sub 1
### five sub 1 sub 1
## five sub 2
			</td>
		</tr>
	</tbody>
</table>

=== HTML Tags ===
<table border="1" style="width: 100%; border-collapse: collapse;">
	<col span="3" width="33%" />
	<thead>
		<tr>
			<th>Description</th>
			<th>Markup</th>
			<th>Output</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Preformatted</td>
			<td>
<pre>
&lt;pre>
Text is *preformatted*,
and markup is _ignored_.
&lt;/pre>
</pre>
			</td>
			<td>
<pre>
Text is *preformatted*,
and markup is _ignored_.
</pre>
			</td>
		</tr>
	</tbody>
</table>

=== Internal Links ===
<table border="1" style="width: 100%; border-collapse: collapse;">
	<col span="3" width="33%" />
	<thead>
		<tr>
			<th>Description</th>
			<th>Markup</th>
			<th>Output</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Internal Link</td>
			<td>
				<pre>[[Main Page]]</pre>
			</td>
			<td>[[Main Page]]</td>
		</tr>
		<tr>
			<td>Piped Link</td>
			<td>
				<pre>[[Main Page|different text]]</pre>
			</td>
			<td>[[Main Page|different text]]</td>
		</tr>
		<tr>
			<td>Hide namespace shortcut</td>
			<td>
				<pre>[[Help:Contents|]]</pre>
			</td>
			<td>[[Help:Contents|]]</td>
		</tr>
		<tr>
			<td>Word-ending links</td>
			<td>
<pre>
[[Help]]s

[[Help]]ing

[[Help]]ers

[[Help]]anylettersyoulikehere
</pre>
			</td>
			<td>
[[Help]]s

[[Help]]ing

[[Help]]ers

[[Help]]anylettersyoulikehere
			</td>
		</tr>
		<tr>
			<td>Avoiding word-ending links</td>
			<td>
				<pre>[[Help]]&lt;nowiki />ful advice</pre>
			</td>
			<td>[[Help]]<nowiki />ful advice</td>
		</tr>
	</tbody>
</table>

=== External Links ===
<table border="1" style="width: 100%; border-collapse: collapse;">
	<col span="3" width="33%" />
	<thead>
		<tr>
			<th>Description</th>
			<th>Markup</th>
			<th>Output</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>External link</td>
			<td>
				<pre>http://google.com</pre>
			</td>
			<td>http://google.com</td>
		</tr>
		<tr>
			<td>External link with different label</td>
			<td>
				<pre>[http://google.com Google]</pre>
			</td>
			<td>[http://google.com Google]</td>
		</tr>
		<tr>
			<td>Mailto link</td>
			<td>
				<pre>[mailto:info@example.org email me]</pre>
			</td>
			<td>[mailto:info@example.org email me]</td>
		</tr>
		<tr>
			<td>Mailto named with subject line and body</td>
			<td>
				<pre>[mailto:info@example.org?Subject=URL%20Encoded%20Subject&body=Body%20Text info]</pre>
			</td>
			<td>[mailto:info@example.org?Subject=URL%20Encoded%20Subject&body=Body%20Text info]</td>
		</tr>
	</tbody>
</table>
