import re, sys
for path in sys.argv[1:]:
    out = []
    for line in open(path, encoding='utf-8').read().split('\n'):
        m = re.match(r'^((?:    )*)(.*)$', line)
        out.append('\t' * (len(m.group(1)) // 4) + m.group(2))
    open(path, 'w', encoding='utf-8').write('\n'.join(out))
    print('indentado:', path)
