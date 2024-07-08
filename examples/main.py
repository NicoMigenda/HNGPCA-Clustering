from hngpca.classes.hngpca import HNGPCA
import scipy.io

# Example usage
if __name__ == "__main__":
    hngpca = HNGPCA()
    mat = scipy.io.loadmat('s1.mat')
