contract;

abi MyContract {
    fn keccak_f1600_state_permute();
}

// Constants
const KECCAK_F_ROUND_CONSTANTS: [u64; 24] = [    // [12 rows of 2 64bit values: 24*8=192 bytes]
    0x0000000000000001, 0x0000000000008082,
    0x800000000000808a, 0x8000000080008000,
    0x000000000000808b, 0x0000000080000001,
    0x8000000080008081, 0x8000000000008009,
    0x000000000000008a, 0x0000000000000088,
    0x0000000080008009, 0x000000008000000a,
    0x000000008000808b, 0x800000000000008b,
    0x8000000000008089, 0x8000000000008003,
    0x8000000000008002, 0x8000000000000080,
    0x000000000000800a, 0x800000008000000a,
    0x8000000080008081, 0x8000000000008080,
    0x0000000080000001, 0x8000000080008008
];
const NROUNDS: u8 = 24;

impl MyContract for Contract {
    fn keccak_f1600_state_permute() {

        // Variables
        let mut shake256_context64: [u64; 26] = 
        [
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0,
        ];
        let mut round: u64 = 0;

        let mut Aba: u64 = shake256_context64[0];
        let mut Abe: u64 = shake256_context64[1];
        let mut Abi: u64 = shake256_context64[2];
        let mut Abo: u64 = shake256_context64[3];
        let mut Abu: u64 = shake256_context64[4];
        let mut Aga: u64 = shake256_context64[5];
        let mut Age: u64 = shake256_context64[6];
        let mut Agi: u64 = shake256_context64[7];
        let mut Ago: u64 = shake256_context64[8];
        let mut Agu: u64 = shake256_context64[9];
        let mut Aka: u64 = shake256_context64[10];
        let mut Ake: u64 = shake256_context64[11];
        let mut Aki: u64 = shake256_context64[12];
        let mut Ako: u64 = shake256_context64[13];
        let mut Aku: u64 = shake256_context64[14];
        let mut Ama: u64 = shake256_context64[15];
        let mut Ame: u64 = shake256_context64[16];
        let mut Ami: u64 = shake256_context64[17];
        let mut Amo: u64 = shake256_context64[18];
        let mut Amu: u64 = shake256_context64[19];
        let mut Asa: u64 = shake256_context64[20];
        let mut Ase: u64 = shake256_context64[21];
        let mut Asi: u64 = shake256_context64[22];
        let mut Aso: u64 = shake256_context64[23];
        let mut Asu: u64 = shake256_context64[24];

        while round < NROUNDS {
            //////////////////////////////////////////////////
            // prepareTheta
            let mut BCa: u64 = Aba ^ Aga ^ Aka ^ Ama ^ Asa;
            let mut BCe: u64 = Abe ^ Age ^ Ake ^ Ame ^ Ase;
            let mut BCi: u64 = Abi ^ Agi ^ Aki ^ Ami ^ Asi;
            let mut BCo: u64 = Abo ^ Ago ^ Ako ^ Amo ^ Aso;
            let mut BCu: u64 = Abu ^ Agu ^ Aku ^ Amu ^ Asu;

            //////////////////////////////////////////////////
            // thetaRhoPiChiIotaPrepareTheta(round  , A, E)
            let mut Da = BCu ^ ((BCe) << (1)) ^ ((BCe) >> (64 - (1)));
            let mut De = BCa ^ ((BCi) << (1)) ^ ((BCi) >> (64 - (1)));
            let mut Di = BCe ^ ((BCo) << (1)) ^ ((BCo) >> (64 - (1)));
            let mut Do = BCi ^ ((BCu) << (1)) ^ ((BCu) >> (64 - (1)));
            let mut Du = BCo ^ ((BCa) << (1)) ^ ((BCa) >> (64 - (1)));
            Aba = Aba ^ Da;
            BCa = Aba;

            Age = Age ^ De;
            BCe = ((Age) << (44)) ^ ((Age) >> (64 - (44)));
            Aki = Aki ^ Di;
            BCi = ((Aki) << (43)) ^ ((Aki) >> (64 - (43)));
            Amo = Amo ^ Do;
            BCo = ((Amo) << (21)) ^ ((Amo) >> (64 - (21)));
            Asu = Asu ^ Du;
            BCu = ((Asu) << (14)) ^ ((Asu) >> (64 - (14)));
            let mut Eba = BCa ^ (!(BCe) & BCi);
            let mut Eba = Eba ^ KECCAK_F_ROUND_CONSTANTS[round];
            let mut Ebe = BCe ^ ((!BCi) & BCo);
            let mut Ebi = BCi ^ (!(BCo) & BCu);
            let mut Ebo = BCo ^ (!(BCu) & BCa);
            let mut Ebu = BCu ^ (!(BCa) & BCe);

            Abo = Abo ^ Do;
            BCa = ((Abo) << (28)) ^ ((Abo) >> (64 - (28)));
            Agu = Agu ^ Du;
            BCe = ((Agu) << (20)) ^ ((Agu) >> (64 - (20)));
            Aka = Aka ^ Da;
            BCi = ((Aka) << (3)) ^ ((Aka) >> (64 - (3)));
            Ame = Ame ^ De;
            BCo = ((Ame) << (45)) ^ ((Ame) >> (64 - (45)));
            Asi = Asi ^ Di;
            BCu = ((Asi) << (61)) ^ ((Asi) >> (64 - (61)));
            let mut Ega = BCa ^ ((!BCe) & BCi);
            let mut Ege = BCe ^ ((!BCi) & BCo);
            let mut Egi = BCi ^ ((!BCo) & BCu);
            let mut Ego = BCo ^ ((!BCu) & BCa);
            let mut Egu = BCu ^ ((!BCa) & BCe);

            Abe = Abe ^ De;
            BCa = ((Abe) << (1)) ^ ((Abe) >> (64 - (1)));
            Agi = Agi ^ Di;
            BCe = ((Agi) << (6)) ^ ((Agi) >> (64 - (6)));
            Ako = Ako ^ Do;
            BCi = ((Ako) << (25)) ^ ((Ako) >> (64 - (25)));
            Amu = Amu ^ Du;
            BCo = ((Amu) << (8)) ^ ((Amu) >> (64 - (8)));
            Asa = Asa ^ Da;
            BCu = ((Asa) << (18)) ^ ((Asa) >> (64 - (18)));
            let mut Eka = BCa ^ ((!BCe) & BCi);
            let mut Eke = BCe ^ ((!BCi) & BCo);
            let mut Eki = BCi ^ ((!BCo) & BCu);
            let mut Eko = BCo ^ ((!BCu) & BCa);
            let mut Eku = BCu ^ ((!BCa) & BCe);

            Abu = Abu ^ Du;
            BCa = ((Abu) << (27)) ^ ((Abu) >> (64 - (27)));
            Aga = Aga ^ Da;
            BCe = ((Aga) << (36)) ^ ((Aga) >> (64 - (36)));
            Ake = Ake ^ De;
            BCi = ((Ake) << (10)) ^ ((Ake) >> (64 - (10)));
            Ami = Ami ^ Di;
            BCo = ((Ami) << (15)) ^ ((Ami) >> (64 - (15)));
            Aso = Aso ^ Do;
            BCu = ((Aso) << (56)) ^ ((Aso) >> (64 - (56)));
            let mut Ema = BCa ^ ((!BCe) & BCi);
            let mut Eme = BCe ^ ((!BCi) & BCo);
            let mut Emi = BCi ^ ((!BCo) & BCu);
            let mut Emo = BCo ^ ((!BCu) & BCa);
            let mut Emu = BCu ^ ((!BCa) & BCe);

            Abi = Abi ^ Di;
            BCa = ((Abi) << (62)) ^ ((Abi) >> (64 - (62)));
            Ago = Ago ^ Do;
            BCe = ((Ago) << (55)) ^ ((Ago) >> (64 - (55)));
            Aku = Aku ^ Du;
            BCi = ((Aku) << (39)) ^ ((Aku) >> (64 - (39)));
            Ama = Ama ^ Da;
            BCo = ((Ama) << (41)) ^ ((Ama) >> (64 - (41)));
            Ase = Ase ^ De;
            BCu = ((Ase) << (2)) ^ ((Ase) >> (64 - (2)));
            let mut Esa = BCa ^ ((!BCe) & BCi);
            let mut Ese = BCe ^ ((!BCi) & BCo);
            let mut Esi = BCi ^ ((!BCo) & BCu);
            let mut Eso = BCo ^ ((!BCu) & BCa);
            let mut Esu = BCu ^ ((!BCa) & BCe);

            //////////////////////////////////////////////////
            // prepareTheta
            // BCa = Eba ^ Ega ^ Eka ^ Ema ^ Esa;
            // BCe = Ebe ^ Ege ^ Eke ^ Eme ^ Ese;
            // BCi = Ebi ^ Egi ^ Eki ^ Emi ^ Esi;
            // BCo = Ebo ^ Ego ^ Eko ^ Emo ^ Eso;
            // BCu = Ebu ^ Egu ^ Eku ^ Emu ^ Esu;

            // //////////////////////////////////////////////////
            // // thetaRhoPiChiIotaPrepareTheta(round+1, E, A)
            // let mut Da = BCu ^ ((BCe) << (1)) ^ ((BCe) >> (64 - (1)));
            // let mut De = BCa ^ ((BCi) << (1)) ^ ((BCi) >> (64 - (1)));
            // let mut Di = BCe ^ ((BCo) << (1)) ^ ((BCo) >> (64 - (1)));
            // let mut Do = BCi ^ ((BCu) << (1)) ^ ((BCu) >> (64 - (1)));
            // let mut Du = BCo ^ ((BCa) << (1)) ^ ((BCa) >> (64 - (1)));
            // Eba = Eba ^ Da;
            // BCa = Eba;



            round += 1;
        }
    }
}
