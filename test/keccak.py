A0 = [[1,2,3,4,5],[10,20,30,40,50],[100,200,300,400,500],[1000,2000,3000,4000,5000],[0,4,65536,27,7625597484987]]
BC = [0,0,0,0,0]
D = [0,0,0,0,0]
E = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
G = [[ 0, 1,62,28,27],\
     [36,44, 6,55,20],\
     [ 3,10,43,25,39],\
     [41,45,15,21, 8],\
     [18, 2,61,56,14]]

IB = ['b','g','k','m','s']
IA = ['a','e','i','o','u']

def rol(b, m):
    "Works only for 64-bit"
    if not m:
        return b
    u = b >> m
    u = u << m
    l = b - u
    return (u >> (64 - m)) + (l << m)

def copymatrix(A):
    Aclone = [0]*len(A)
    for k in range(len(A)):
        Aclone[k] = A[k].copy()
    return Aclone

def randommatrix():
    from random import randint
    A = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    for j in range(5):
        for k in range(5):
            A[j][k] = randint(-2**63, 2**63 - 1)
    return A

################################################################################
def mulligan(A, G):
    """ Mulliganaceous' modified Keccak function"""
    for g in A:
        print("[{0:16x} {1:16x} {2:16x} {3:16x} {4:16x}]".format(g[0], g[1], g[2], g[3], g[4]))
    # Produce the initial BC and D vector
    for k in range(5):
        BC[k] = (A[0][k] ^ A[1][k] ^ A[2][k] ^ A[3][k] ^ A[4][k])
    for k in range(5):
        D[k] = BC[(k - 1) % 5] ^ rol(BC[(k + 1) % 5], 1)
    print("\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BC[0], BC[1], BC[2], BC[3], BC[4]))
    print("\tD\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(D[0], D[1], D[2], D[3], D[4]))
        
    # Ex: Note k is from a,e,i,o,u or b,g,k,m,s
    j = 0
    offset = 0
    for j in range(5):
        for k in range(5):
            koffset = (k + offset) % 5
            A[k][koffset] ^= D[koffset]
            BC[k] = rol(A[k][koffset], G[k][koffset])
            #print(" I\t\t{0:s}{1:s} {2:d}".format(IB[k], IA[koffset], G[k][koffset]))
        for k in range(5):
            koffset = (k + offset) % 5
            E[j][k] = BC[k] ^ (~BC[(k + 1)%5] & BC[(k + 2)%5])
            
        print(" {0:s}\t A\t{1:016x},{2:016x},{3:016x},{4:016x},{5:016x}".format(IB[j], A[0][offset % 5], A[1][(1 + offset) % 5], A[2][(2 + offset) % 5], A[3][(3 + offset) % 5], A[4][(4 + offset) % 5]))
        print(" {0:s}\t BC\t{1:016x},{2:016x},{3:016x},{4:016x},{5:016x}".format(IB[j], BC[0], BC[1], BC[2], BC[3], BC[4]))
        print(" {0:s}\t E\t{1:016x},{2:016x},{3:016x},{4:016x},{5:016x}\n".format(IB[j], E[j][0], E[j][1], E[j][2], E[j][3], E[j][4]))
        offset += 3

    return E

def keccak(A):
    """ Original code """
    for g in A:
        print("[{0:16x} {1:16x} {2:16x} {3:16x} {4:16x}]".format(g[0], g[1], g[2], g[3], g[4]))
        
    Aba = A[0][0]; Abe = A[0][1]; Abi = A[0][2]; Abo = A[0][3]; Abu = A[0][4];
    Aga = A[1][0]; Age = A[1][1]; Agi = A[1][2]; Ago = A[1][3]; Agu = A[1][4];
    Aka = A[2][0]; Ake = A[2][1]; Aki = A[2][2]; Ako = A[2][3]; Aku = A[2][4];
    Ama = A[3][0]; Ame = A[3][1]; Ami = A[3][2]; Amo = A[3][3]; Amu = A[3][4];
    Asa = A[4][0]; Ase = A[4][1]; Asi = A[4][2]; Aso = A[4][3]; Asu = A[4][4];

    BCa = Aba ^ Aga ^ Aka ^ Ama ^ Asa;
    BCe = Abe ^ Age ^ Ake ^ Ame ^ Ase;
    BCi = Abi ^ Agi ^ Aki ^ Ami ^ Asi;
    BCo = Abo ^ Ago ^ Ako ^ Amo ^ Aso;
    BCu = Abu ^ Agu ^ Aku ^ Amu ^ Asu;

    Da = BCu ^ rol(BCe, 1);
    De = BCa ^ rol(BCi, 1);
    Di = BCe ^ rol(BCo, 1);
    Do = BCi ^ rol(BCu, 1);
    Du = BCo ^ rol(BCa, 1);

    print(">\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">\tD\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Da, De, Di, Do, Du))
    
    Aba ^= Da;
    BCa = Aba;
    Age ^= De;
    BCe = rol(Age, 44);
    Aki ^= Di;
    BCi = rol(Aki, 43);
    Amo ^= Do;
    BCo = rol(Amo, 21);
    Asu ^= Du;
    BCu = rol(Asu, 14);
    Eba = BCa ^ ((~BCe) & BCi);
    Ebe = BCe ^ ((~BCi) & BCo);
    Ebi = BCi ^ ((~BCo) & BCu);
    Ebo = BCo ^ ((~BCu) & BCa);
    Ebu = BCu ^ ((~BCa) & BCe);
    print(">b\tA\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(Aba, Age, Aki, Amo, Asu))
    print(">b\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">b\tE\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Eba, Ebe, Ebi, Ebo, Ebu))

    Abo ^= Do;
    BCa = rol(Abo, 28);
    Agu ^= Du;
    BCe = rol(Agu, 20);
    Aka ^= Da;
    BCi = rol(Aka, 3);
    Ame ^= De;
    BCo = rol(Ame, 45);
    Asi ^= Di;
    BCu = rol(Asi, 61);
    Ega = BCa ^ ((~BCe) & BCi);
    Ege = BCe ^ ((~BCi) & BCo);
    Egi = BCi ^ ((~BCo) & BCu);
    Ego = BCo ^ ((~BCu) & BCa);
    Egu = BCu ^ ((~BCa) & BCe);
    print(">g\tA\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(Abo, Agu, Aka, Ame, Asi))
    print(">g\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">g\tE\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Ega, Ege, Egi, Ego, Egu))

    Abe ^= De;
    BCa = rol(Abe, 1);
    Agi ^= Di;
    BCe = rol(Agi, 6);
    Ako ^= Do;
    BCi = rol(Ako, 25);
    Amu ^= Du;
    BCo = rol(Amu, 8);
    Asa ^= Da;
    BCu = rol(Asa, 18);
    Eka = BCa ^ ((~BCe) & BCi);
    Eke = BCe ^ ((~BCi) & BCo);
    Eki = BCi ^ ((~BCo) & BCu);
    Eko = BCo ^ ((~BCu) & BCa);
    Eku = BCu ^ ((~BCa) & BCe);
    print(">k\tA\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(Abe, Agi, Ako, Amu, Asa))
    print(">k\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">k\tE\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Eka, Eke, Eki, Eko, Eku))

    Abu ^= Du;
    BCa = rol(Abu, 27);
    Aga ^= Da;
    BCe = rol(Aga, 36);
    Ake ^= De;
    BCi = rol(Ake, 10);
    Ami ^= Di;
    BCo = rol(Ami, 15);
    Aso ^= Do;
    BCu = rol(Aso, 56);
    Ema = BCa ^ ((~BCe) & BCi);
    Eme = BCe ^ ((~BCi) & BCo);
    Emi = BCi ^ ((~BCo) & BCu);
    Emo = BCo ^ ((~BCu) & BCa);
    Emu = BCu ^ ((~BCa) & BCe);
    print(">m\tA\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(Abu, Aga, Ake, Ami, Aso))
    print(">m\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">m\tE\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Ema, Eme, Emi, Emo, Emu))
    
    Abi ^= Di;
    BCa = rol(Abi, 62);
    Ago ^= Do;
    BCe = rol(Ago, 55);
    Aku ^= Du;
    BCi = rol(Aku, 39);
    Ama ^= Da;
    BCo = rol(Ama, 41);
    Ase ^= De;
    BCu = rol(Ase, 2);
    Esa = BCa ^ ((~BCe) & BCi);
    Ese = BCe ^ ((~BCi) & BCo);
    Esi = BCi ^ ((~BCo) & BCu);
    Eso = BCo ^ ((~BCu) & BCa);
    Esu = BCu ^ ((~BCa) & BCe);
    print(">s\tA\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(Abi, Ago, Aku, Ama, Ase))
    print(">s\tBC\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}".format(BCa, BCe, BCi, BCo, BCu))
    print(">s\tE\t{0:016x},{1:016x},{2:016x},{3:016x},{4:016x}\n".format(Esa, Ese, Esi, Eso, Esu))

    return [[Eba, Ebe, Ebi, Ebo, Ebu],\
            [Ega, Ege, Egi, Ego, Egu],\
            [Eka, Eke, Eki, Eko, Eku],\
            [Ema, Eme, Emi, Emo, Emu],\
            [Esa, Ese, Esi, Eso, Esu]]

################################################################################
print("\nMULLIGANACEOUS' METHOD")
A = copymatrix(A0)
A2 = mulligan(A, G)
for g in A:
    print(" A\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
print()
for g in A2:
    print(" E\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
print("\nVERBATIM ORIGINAL CODE FROM SOLIDITY")
A = copymatrix(A0)
A2 = keccak(A)
for g in A:
    print(">A\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
print()
for g in A2:
    print(">E\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
print()

for k in range(24):
    A0 = randommatrix()
    print("\nMULLIGANACEOUS' METHOD")
    A = copymatrix(A0)
    A1 = mulligan(A, G)
    for g in A:
        print(" A\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
    print()
    for g in A1:
        print(" E\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
    print("\nVERBATIM ORIGINAL CODE FROM SOLIDITY")
    A = copymatrix(A0)
    A2 = keccak(A)
    for g in A:
        print(">A\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
    print()
    for g in A2:
        print(">E\t[{0:016x} {1:016x} {2:016x} {3:016x} {4:016x}]".format(g[0], g[1], g[2], g[3], g[4]))
    print()
    for i in range(5):
        for j in range(5):
            if A1[i][j] != A2[i][j]:
                raise Exception(hex(A1[i][j]), hex(A2[i][j]), (i,j))
