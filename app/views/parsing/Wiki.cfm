== Formatting ==
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
* Line breaks<br />don't break levels.
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
# Line breaks<br />don't break levels.
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
