#!/usr/bin/env bash
exec /usr/bin/java -Xmx512M -cp "$(find /opt/language_tool -name languagetool-server.jar)" org.languagetool.server.HTTPServer --config /etc/language-tool.properties --public -p 8100
