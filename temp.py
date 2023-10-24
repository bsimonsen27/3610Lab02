import numpy as np

def main():
    file = open('workfile.txt', 'w')
    t = np.linspace(0,1,100000)
    x = np.sin(2*np.pi*t)
    f = .5*x + .5
    f *= 4095
    
    for i in range(0, len(f)):
        file.write(str(hex(int(f[i]))) + ",\n")
        
if __name__ == "__main__":
    main()

