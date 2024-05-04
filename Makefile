.PHONY: help l10n-extract-to-arb l10n-generate-from-arb

help:
	@ echo 'Available commands:'
	@ echo
	@ echo '  l10n-extract-to-arb    : Extract app_localizations.dart into intl_messages.arb'
	@ echo '                           Duplicate content of intl_messages.arb into intl_xx.arb'
	@ echo '  l10n-generate-from-arb : Generate messages_*.dart files from intl_*.arb'
	@ echo
	@ echo

l10n-extract-to-arb:
	dart run intl_translation:extract_to_arb --output-dir=lib/languages lib/languages/app_localizations.dart 

l10n-generate-from-arb:
	dart run intl_translation:generate_from_arb --output-dir=lib/languages --no-use-deferred-loading lib/languages/app_localizations.dart lib/languages/intl_*.arb
