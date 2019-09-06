import pickle

def pickle_save(x,y):
        with open(x,'wb') as f:
                pickle.dump(y,f)
