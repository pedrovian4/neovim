; Inject PHP into @php...@endphp blocks
((php_directive) @injection.content
 (#set! injection.language "php"))

; Inject PHP into <?php...?> blocks
((php_block) @injection.content
 (#set! injection.language "php"))
