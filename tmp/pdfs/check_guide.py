from pathlib import Path
from PIL import Image,ImageOps,ImageDraw
from pypdf import PdfReader
root=Path('tmp/pdfs')
files=sorted(root.glob('page-*.png'))
for offset in (0,6):
    canvas=Image.new('RGB',(1416,2040),'#dce2e6')
    for k,f in enumerate(files[offset:offset+6]):
        im=Image.open(f).convert('RGB');im.thumbnail((688,970))
        x=10+(k%2)*708;y=20+(k//2)*680
        im.thumbnail((470,650))
        x=105+(k%2)*708
        canvas.paste(im,(x,y))
        ImageDraw.Draw(canvas).text((x,y+650),f'Page {offset+k+1}',fill='black')
    canvas.save(root/f'overview-{offset}.png')
r=PdfReader('output/pdf/Comprendre_Flutter_Nocturne.pdf')
for i,p in enumerate(r.pages):
    text=p.extract_text()
    print(f'Page {i+1}: {len(text)} caractères; début: {text[:85]!r}')
    assert '\ufffd' not in text
assert len(r.pages)==11
