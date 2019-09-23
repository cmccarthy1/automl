import pickle

def pickle_save(x,y):
        with open(x,'wb') as f:
                pickle.dump(y,f)

def pickle_load(x):
        with open(x,'rb') as f:
                pickle.load(f)
