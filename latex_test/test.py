import numpy as np
import pylatex as pl
import pandas as pd

df = pd.DataFrame({'a': [1,2,3], 'b': [9,8,7]})
df.index.name = 'x'

M = np.matrix(df.values)

doc = pl.Document()

doc.packages.append(pl.Package('booktabs'))

with doc.create(pl.Section('Matrix')):
    doc.append(pl.Math(data=[pl.Matrix(M)]))

# Difference to the other answer:
with doc.create(pl.Section('Table')):
    with doc.create(pl.Table(position='htbp')) as table:
        table.add_caption('Test')
        table.append(pl.Command('centering'))
        table.append(pl.NoEscape(df.to_latex(escape=False)))


doc.generate_pdf('full', clean_tex=False)
