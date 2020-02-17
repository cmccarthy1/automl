import pylatex as pl
from pylatex import Document, Section, Subsection, Command, Figure, NewPage, Center
from pylatex.utils import italic, NoEscape

def createTable(doc,tab,ncols):
  with doc.create(Center()) as centered:
    with centered.create(pl.Tabular(ncols)) as table:
      table.add_hline()
      table.add_row(list(tab.columns))
      table.add_hline()
      for row in tab.index:
        table.add_row(list(tab.loc[row,:]))
      table.add_hline()

def createImage(doc,img,caption):
  with doc.create(Figure(position='h!')) as images:
     images.add_image(img,width = NoEscape(r'0.75\textwidth'))
     images.add_caption(caption)

def test_doc(dict,tb,scr):
  geometry_options = {"margin": "2.5cm"}
  doc = Document('testing_doc',  geometry_options=geometry_options)
  doc.preamble.append(Command('title', 'kdb+/q Automate Machine Learning Generated Report'))
  doc.preamble.append(Command('author', 'KxSystems'))
  doc.preamble.append(Command('date', 'Date: ' + dict['date']))
  doc.append(NoEscape(r'\maketitle'))

  with doc.create(Section('Introduction')):
    doc.append('This report outlines the results achieved through the running') 
    doc.append('of the kdb+/q automated machine learning framework.\n')
    doc.append('This run started on ' + dict['date'] + ' at ' + dict['time'])

  with doc.create(Section('Description of input data')):
    doc.append('The following is a breakdown of information for a number of the relevant columns in the dataset\n\n')
    createTable(doc,tb,'cccccccc')

  with doc.create(Section('Pre-processing Breakdown')):
    doc.append('Following the extraction of features a total of ' + dict['num_feat'] + ' features were produced\n')
    doc.append('Feature extraction took a total time of ' + dict['feat_time'] + '.\n\n')

  doc.append(NewPage())

  with doc.create(Section('Initial Scores')):
    doc.append(dict['xv_folds']+'-fold cross validation was performed on the training set using ' + dict['xv_func'])
    createImage(doc,'test.png','This image shows how the data is split into training, testing and validation sets')
    doc.append('The total time that was required to complete selection of the best model based on the training set was ' + dict['xvtime'])
    doc.append('\n\nThe metric that is being used for scoring and optimising the models was ' + dict['metric'] + '\n\n')
    createTable(doc,scr,'cc')
    createImage(doc,'test.png','This is the feature impact for a number of the most significant features as determined on the training set')

  with doc.create(Section('Model selection summary')):
    doc.append('Best scoring model = ' + dict['best_model'] + '\n\n')
    doc.append('The score on the validation set for this model was = ' + dict['best_val_score'] + '\n\n')
    doc.append('The total time to complete the running of this model on the validation set was: ' + dict['val_score'])
  doc.generate_pdf(clean_tex=False)
