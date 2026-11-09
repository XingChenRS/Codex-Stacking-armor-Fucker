"""Build instructions.md from reference/instructions.md and patches/series.

  python build.py                 apply every patch listed in patches/series
  python build.py capture NAME    save the edits made to instructions.md since the
                                  last build as patches/NNNN-NAME.patch and append
                                  it to the series
"""
import difflib
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent
REFERENCE = ROOT / 'reference' / 'instructions.md'
PATCHES = ROOT / 'patches'
SERIES = PATCHES / 'series'
OUTPUT = ROOT / 'instructions.md'


def series():
    lines = SERIES.read_text(encoding='utf-8').splitlines()
    return [l.strip() for l in lines if l.strip() and not l.lstrip().startswith('#')]


def built_text():
    with tempfile.TemporaryDirectory() as tmp:
        work = pathlib.Path(tmp) / 'instructions.md'
        work.write_bytes(REFERENCE.read_bytes())
        for name in series():
            subprocess.run(['git', 'apply', '--whitespace=nowarn', str(PATCHES / name)], cwd=tmp, check=True)
        return work.read_text(encoding='utf-8')


def build():
    OUTPUT.write_text(built_text(), encoding='utf-8', newline='\n')
    print(f'{OUTPUT.name}: {len(series())} patches applied')


def capture(name):
    before = built_text().splitlines(True)
    after = OUTPUT.read_text(encoding='utf-8').splitlines(True)
    diff = ''.join(difflib.unified_diff(before, after, 'a/instructions.md', 'b/instructions.md', n=3))
    if not diff:
        sys.exit('instructions.md matches the current series.')
    number = len(list(PATCHES.glob('[0-9][0-9][0-9][0-9]-*.patch'))) + 1
    patch = PATCHES / f'{number:04d}-{name}.patch'
    patch.write_text(diff, encoding='utf-8', newline='\n')
    with SERIES.open('a', encoding='utf-8', newline='\n') as f:
        f.write(patch.name + '\n')
    print(f'captured {patch.name}')


if __name__ == '__main__':
    if len(sys.argv) == 3 and sys.argv[1] == 'capture':
        capture(sys.argv[2])
    elif len(sys.argv) == 1:
        build()
    else:
        sys.exit(__doc__)
