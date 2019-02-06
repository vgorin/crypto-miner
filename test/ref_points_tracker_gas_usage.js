const addresses_issued = [
	"0xEd6003e7A6494Db4ABabEB7bDf994A3951ac6e69",
	"0xe66338c67b82fcaa0ac4c8369c74c2b4ec5a0bad",
	"0xfdf03cf3c7a260fdb732929948fd5c3cb39544bf",
	"0x4c83d4dca7b0e92a4b7e108e98f59178680a5acb",
	"0xc69325fe2449fbdc064018b0c0ca246e7067db54",
	"0x220c30ce36bbb22b57bd1c60e9ee4dcf44ca211d",
	"0x183febd8828a9ac6c70c0e27fbf441b93004fc05",
	"0x718ffdc2b4e813e7d200c6086b5425fd6a219cff",
	"0xe820f08968489c466c77c2ea1a5c436d8c70d896",
	"0xd1692f1c6b50d299993363be1c869e3e64842732",
	"0x921e7ebebfb4f37a3770c5ccafc108ac31c8d438",
	"0x360bbad1120b0abf63573e2e21b6727e07d1bf18",
	"0x765fec224e701c36870f088bab3d18648eb765e3",
	"0xc857ec9a3ed2c59cbbc4954f11311fdd7532db15",
	"0x22406c0a2eb0a0a1c4fdabd56f695f205e3fa2d1",
	"0x5d92fd7e52f9ba04abb84d80c1a107dfe51f8473",
	"0xa1559b8c9b52dfdc6300549e3f6a8374b91bd50e",
	"0x80ea4ece903c42497cd7a41f541985c7211d6216",
	"0x0e75143296497f488f0e5a3bb3cf11ed9328fd78",
	"0x965a166c4c6f662fcee05902bf2e137afa80b3a2",
	"0xbbef61229a8d6eb2d6fb5d3a968af24a95984f0e",
	"0xbd55b2e3167637b71dd41e31f84d223930584798",
	"0xd820e895956e5315f813a53b2bb9cea29b6adc61",
	"0x2aab510050bdabcd204c9c6877a2281fc122e946",
	"0x040bfa96615fceed61e68223fef17b72ec0197ff",
	"0xaec539a116fa75e8bdcf016d3c146a25bc1af93b",
	"0x95cd2b7e952cda42d16d21d07c49f66ae14da2ec",
	"0xd1f622d61a11cd420415cb7de5482956d761dbe8",
	"0x726614e49e844aae1c167a293bd06beca8a51705",
	"0xcff9963b8602dfbb7fb0a44c2d5c73aa1bcbff03",
	"0x5c4a99410bbb5fdd330c65488afaaa121e7fb437",
	"0x263b604509d6a825719859ee458b2d91fb7d330d",
	"0xa9232c4ef4725a8a256ab638065ac03eb8651fa0",
	"0x30404a2900e8ea5c08eeeb284e9b2bebfc01c58d",
	"0xf39d65ecfea0497cb5911dc499222f81506ca249",
	"0xd3758d7a3f28b0ebb44be71bb78bdd773b1b14c2",
	"0xa15e09311a8b0fcc8edebdceb427eeaf1cf96d98",
	"0xf5e37e330b170d7c9b7ebec5f6dd92d71a1b45a4",
	"0x573a6bf63ad5e24275f686e9655731cc6048e005",
	"0x22f0146e4ffdf109b7069bb92f4f421edee87d4e",
	"0x91bda0b13aeb5ec89533fcd4f5b190e1ac93f5ca",
	"0x21ae65e0d62775a01ebd6a292994080c91fa92f8",
	"0xb51694051d0294eccda91b62b05c7637b5bf348b",
	"0xb9ace70ce234180f009aee04fc84fd755856fe86",
	"0xbc1b89612b8c8e006929197569818e785e427bfb",
	"0x35632b6976b5b6ec3f8d700fabb7e1e0499c1bfa",
	"0xdd25963251fceb0a7bef9bb713eed260829f5656",
	"0xf73421c341218cb40148a9bdfc60fa7b989576c8",
	"0x8735117d6110ae36fd15ac093046ac9a31b5a9e2",
	"0x6771450accb00177f0392094d3b41e648a96f1e0",
	"0x01af7eeacae5f2303b2b5dafaed55ecb4ebfe0ed",
	"0x4906e4f95ad546ce865916f65c825e00630bffa8",
	"0xe669331ac656ef11ac75391278ba7fb83ae62394",
	"0x254f441fcc7fa80b494c6e65bf8ec0a4e894f282",
	"0xdb856e59b077f9d2548719a71e549a7b61cb78e3",
	"0xfbf13497056f33300ad82511c6a1349dd3d2ae26",
	"0x778f7434956b899303708fa3c5fad85bf9d93e06",
	"0x2845a83d2a6cb264a5e35103ef10472746f43c4d",
	"0x7a92881f55bf105ff5954a637a37f2f9a07dc5a0",
	"0xfefbdc19a0d855a8b9bbf79144bc32cc7eeda019",
	"0x198d5bf898d7cb4531fd35c8a9b9853c915904ea",
	"0x24257f2ffb8b962ff7d48819617b095bea9eae2a",
	"0x983961f34fc4cfc5eafec371cdba9d56ff8c1935",
	"0x8c78481e28dc6b2285099b2c7dc4515680d0dc7c",
	"0xf7ee6c2f811b52c72efd167a1bb3f4adaa1e0f89",
	"0x8fd1ac1c6530acc0a8ca18311925264c9ec9121d",
	"0xcb9b03196f1232c4c3cc16cb806afdd93da4126b",
	"0xf38de5479c638a157812bc959be5892e7d22e8ee"
];

const points_issued = [
	1,
	2,
	1,
	2,
	1,
	4,
	7,
	10,
	1,
	612,
	20,
	30,
	1,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	1,
	18,
	10,
	10,
	10,
	30,
	10,
	5,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	20,
	10,
	22,
	1,
	10,
	10,
	10,
	2,
	4,
	10,
	10,
	1,
	5,
	20,
	2,
	1,
	2,
	1,
	1,
	1,
	1,
	10,
	20,
	1,
	1
];

const addresses_consumed = [
	"0xd1692f1c6b50d299993363be1c869e3e64842732",
	"0x921e7ebebfb4f37a3770c5ccafc108ac31c8d438",
	"0x360bbad1120b0abf63573e2e21b6727e07d1bf18",
	"0xc857ec9a3ed2c59cbbc4954f11311fdd7532db15",
	"0x22406c0a2eb0a0a1c4fdabd56f695f205e3fa2d1",
	"0x5d92fd7e52f9ba04abb84d80c1a107dfe51f8473",
	"0xa1559b8c9b52dfdc6300549e3f6a8374b91bd50e",
	"0x80ea4ece903c42497cd7a41f541985c7211d6216",
	"0x0e75143296497f488f0e5a3bb3cf11ed9328fd78",
	"0x965a166c4c6f662fcee05902bf2e137afa80b3a2",
	"0xbbef61229a8d6eb2d6fb5d3a968af24a95984f0e",
	"0xbd55b2e3167637b71dd41e31f84d223930584798",
	"0xd820e895956e5315f813a53b2bb9cea29b6adc61",
	"0x2aab510050bdabcd204c9c6877a2281fc122e946",
	"0x95cd2b7e952cda42d16d21d07c49f66ae14da2ec",
	"0xd1f622d61a11cd420415cb7de5482956d761dbe8",
	"0x726614e49e844aae1c167a293bd06beca8a51705",
	"0xcff9963b8602dfbb7fb0a44c2d5c73aa1bcbff03",
	"0xa9232c4ef4725a8a256ab638065ac03eb8651fa0",
	"0x30404a2900e8ea5c08eeeb284e9b2bebfc01c58d",
	"0xf39d65ecfea0497cb5911dc499222f81506ca249",
	"0xd3758d7a3f28b0ebb44be71bb78bdd773b1b14c2",
	"0xa15e09311a8b0fcc8edebdceb427eeaf1cf96d98",
	"0xf5e37e330b170d7c9b7ebec5f6dd92d71a1b45a4",
	"0x573a6bf63ad5e24275f686e9655731cc6048e005",
	"0x22f0146e4ffdf109b7069bb92f4f421edee87d4e",
	"0x91bda0b13aeb5ec89533fcd4f5b190e1ac93f5ca",
	"0x21ae65e0d62775a01ebd6a292994080c91fa92f8",
	"0xb51694051d0294eccda91b62b05c7637b5bf348b",
	"0xb9ace70ce234180f009aee04fc84fd755856fe86",
	"0xf73421c341218cb40148a9bdfc60fa7b989576c8",
	"0x8735117d6110ae36fd15ac093046ac9a31b5a9e2",
	"0x6771450accb00177f0392094d3b41e648a96f1e0",
	"0xe669331ac656ef11ac75391278ba7fb83ae62394",
	"0x254f441fcc7fa80b494c6e65bf8ec0a4e894f282",
	"0x778f7434956b899303708fa3c5fad85bf9d93e06",
	"0x8fd1ac1c6530acc0a8ca18311925264c9ec9121d"
];

const points_consumed = [
	600,
	20,
	30,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	30,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	10,
	20,
	10,
	10,
	10,
	10,
	10,
	20,
	20
];

const known_addresses = [
	"0x5269bf8720946b5c38fbf361a947ba9d30c91313",
	"0x02bec39d210a6753b97f16f06ed4b4140e948f3b",
	"0xc91b7696d0cf011f98738c8d1d65abd172f4823d",
	"0x0a19b2ac2da8b86de5d34fcdc98f029c28b1becb",
	"0x5f9743f110524e49450a8222aa449fe3d227e51b",
	"0x2af3eb7cab5b35f046ccc3b81ab484dfbe431ac3",
	"0x242d0c57a9ff0391ff7fd3a050cf7edb4f821050",
	"0xf2c74f54bda3a08a65fc83cd3bcc6df0d1d7f046",
	"0x0a27fa2e2f5bfd497653786bb75048de340d3242",
	"0x630198f7a7ba302dcb3595a82f60930d83747ef7",
	"0x2a2ce75c33867a116c3cf985e61b0632a2220c94",
	"0x70a7c5104f8c4cb202b9161657b5fa79cd44c4c4",
	"0x53e5bfa3fe947efafd6b8e765e319943e0cb9c5a",
	"0x7d001db2dc940b600f3494444b1a8082b388031b",
	"0x371c748e0b3eacadf7bf96c67b7bc9ce26de5367",
	"0x4be640dcce08e68ede454202fbc59cf5f9e8ea1f",
	"0xffbc6441ea7cd86f7c552f9bb825106b419c4041",
	"0x2f0477cfa76a80634a011258ea88915519344da4",
	"0x20ca0d6fe51d06946f5cc90f9f4f297d398dd6db",
	"0x3e3291e45a55a4b160dd4a3b81c3367b79f818d3",
	"0x110f5169eaa698d2e309b60134468e2ec4e4f84b",
	"0xd048f6c3012aced66717d794258cb7831ccacae1",
	"0xdc61121e24c2d6394df8bfb8885eb04983a1afcd",
	"0xa7cf0d8511d269da2e06a5665f0d8a67f4fe7f2e",
	"0xde341d87cfcd507e918cc37b84e829ac20651470",
	"0x1ecc246891e1430f8bf297547e02887d230c39b6",
	"0x92b9a7b6caacfe68420eda7c1167834a73e383f1",
	"0x72639fd1a1c3e2a9bd6745caf774c6cc57f0c946",
	"0x9e6033fb9bc60653266d35275e764a0b1e0dca4b",
	"0xcf0e9b4746cfb97bae329fe5f696969f6564566a",
	"0x407dbc332f834e51737e428fe22ce10fcdb4214f",
	"0xdbb59151b18dd72e9ac092706e93de5b5d7a9325",
	"0xd0205b4f442a2a4c4fb01cc94f8b5bf1dfd29458",
	"0x13fb97da9d2407da6dbc2d6c175b51d0f5d9d903",
	"0x19a7ecbbfceacb3d67fc69293baf42b2ec83b7cb",
	"0x04b38b5c09e4ec66dd14350393813afba0e60499",
	"0xd75807b73c780b3c11e284cb79a8578f8a1431c6",
	"0xe75156efe028c476e2f790f9c2af18412ea34a72",
	"0x60d38778adbbeeac88f741b833cbb9877228eea0",
	"0xb1a3354deb366b66f1130632fa02a5fd260c57ac",
	"0xcd8d424e25e1aa201091f855a81f28d2556988dd",
	"0x6f69f79cea418024b9e0acfd18bd8de26f9bbe39",
	"0x445ba6f9f553872fa9cdc14f5c0639365b39c140",
	"0xe13d4abee4b304b67c52a56871141cad1b833aa7",
	"0x5d9803ad4c3833d23ea7c124cd643d21c82beb62",
	"0x0a3239799518e7f7f339867a4739282014b97dcf",
	"0x0e42d32dcc5b83a9bc74523af3b8c3a3b4cf107f",
	"0xd9b74f73d933fde459766f74400971b29b90c9d2",
	"0x501e13c2ae8d9232b88f63e87dfa1df28103acb6",
	"0x56f6bf6b793713c050fd02147a45b563bb4d8efa",
	"0xf8856124ea157d6f26472e38224ee6744ad13af3",
	"0x7c0d2f1eb3dc2cc21d6118789d26f2db09311b1d",
	"0x12bcefaff8878f84fdd4ce2f33c3b49ee43de948",
	"0xe76efe742e3588478559b32ce8cfce3d90a47562",
	"0xc24f97bb1d7a75d9f986c99dfcfa2a558058904c",
	"0x9d3f10f5d553dda3f36e09ab0c3c757ba99e8894",
	"0x87a405be5ef6f8770cd4a3088be43da04f5d4339",
	"0xcf3030a358ee55913a030ec3123a0b28bbee7100",
	"0x7eae3aef288fe41409043d6dda05e093cb4d8393",
	"0x5dc4561125fcac2030d07301c50153cfe624391b",
	"0x406f4533b2f6209812d7ef9c7d69b8c54217c208",
	"0x50b574d9ec895effe328f91419cc0c50c0b96c10",
	"0xefd6ebe8b1f1fad587a01e2db7bd1b38bb63149c",
	"0x02e4f0ed407e86d7fb8b2e3f1a295b68f29b19e5",
	"0xae17e79318ee18d2b9ca78937e1581d0e0bc92ce",
	"0xaa4812ead3c0e009995fdbcbbee9211eeaeb42fb",
	"0x70a9e0d9a01cd82c61d717df35210e346e2e5976",
	"0x2643796cb6b4e715140f09c352ea26afff1a7d93",
	"0x45adff324eb1ac03a6a115dc539052232d4ba980",
	"0x3898ce3bdbb13700a7f3a389b46912857da7e12e",
	"0x29ecaa773f052d14ec5258b352ee7304f57aabc3",
	"0x98eec33cea8155db28fd4cf44aa6eda238772900",
	"0x6d140563ddbb79fc89a822390fc15b43e8f1fff1",
	"0x92ad621b2aee473f7730ddab92aad7496a1264e3",
	"0x0498d949fdcb0fe944195b63520b11a956b91b6d",
	"0xbb517df03c2ed2540a5efc92aa2fed3de107983b",
	"0x0c9a2fffe38bd6551187d85535e0d917ff4d83b8",
	"0x59d9cb5463d2798aaaa7ba14dec5fcd2259088ab",
	"0xb3cab0f508598ba4b83573656ecb0de6de8de327",
	"0x4f0d861281161f39c62b790995fb1e7a0b81b07b",
	"0xa9ffaaadd88a819bd76a4d679e833bbd32755ade",
	"0xa1c299326473983c303eebb76e0cb062857cd9cb",
	"0x5441bf9aa27e79c7aa4a8d1b340d16973695dee1",
	"0x41271507434e21dbd5f09624181d7cd70bf06cbf",
	"0x5dbcfa6b00b9617b46f2c6487ea99160bdda7c2f",
	"0xe88598937dafbb655be37f15846d0e5ccc1b035d",
	"0x664138a8744093833517707508df0ee3be6f6af1",
	"0x21d501d1bd903f01ad0ba807e2bb29a8765aee29",
	"0xeace206af7039fe91f5fd047f03118d4d7d4f8ba",
	"0x3c6afd05bb0f423231f09f1f1fa49c0f1fded42e",
	"0xe0a4490620e9e156f2c73f4afd905abdfbac1a4a",
	"0x1219819360136a93ac14e4df0a90125cf9927616",
	"0xa14ac1a9b3d52abd0652c5aca346099a6eb16b54",
	"0x3034c86219965f358cde28df6723cb8fa366f38b",
	"0x5603000620416ae0e75a44c05b5082171104b46c",
	"0xdc3673039db80e7c79a9dc6aa08f41691082ac2f",
	"0xfdd17f00be3bbf8f065366ddf939fa2d9acde212",
	"0x5963a6bdbcac131b6a018858d3a6c39f6126d2c4",
	"0x5a0ebd2690bd9d309b6923f9d931e2c965045ad9",
	"0x2781b553cae0f0502ee4a6c38cb6459badef17e8",
	"0x51875a06abf8586258a17442afa063a06f18930a",
	"0xfe99f263a32f51b896be1e5bf9294f07a1790dad",
	"0x3bc566525b4016e84e63211d590bfbf65c23212e",
	"0x8cb4ed384f99d35311f21d3126e93c7dfe74a32d",
	"0xd95c9809b6e7f404488d52c8d82e6d095b37a190",
	"0xd05f5687fc24bcb8830f86fb6f389925ccd3b2f5",
	"0xaa9fa8dd95f830409e00202c54cba39e68e23972",
	"0x1f7f2aea059bbe8b9a710b7f33f4f6e1382412ec",
	"0x8afbf75238f4653a0a3dd134129db195e566f4c3",
	"0x504af27f1cef15772370b7c04b5d9d593ee729f5",
	"0x0574a828be55547b5b7cf68681e8d357f494ee53",
	"0xb9fedb203920981e26d84a4dea867b4927085074",
	"0x74f3e7a15099a653885bcc8c31d354fef7c221c1",
	"0xa2381223639181689cd6c46d38a1a4884bb6d83c",
	"0x313bdc9726d8792ec4bd8531caa52a1dd82bd4ea",
	"0xad565956ae5bd43117f6b0a650ec18c621ff8e0d",
	"0x76990237ea27b27e598c3923fbc8ebb52a01e394",
	"0xe1fd79d04f1055cd16f2ada5a508aa193a9fbe7f",
	"0xd5db73a94049706326f84815181df3d4d3323070",
	"0x8e662143178bb8c797620a3a61f34a71832475b0",
	"0x6100df1acd9d2db45cb86a48e524963ae20557ed",
	"0x6c4ff1459cc4d95b9a7a7b20a3bc09bc2404b9a7",
	"0x21b804927286c058b4cf819d65a3b0721aae2333",
	"0x7f96fdf9f7c8bb1d3d56c4d0daf0345c243945ce",
	"0xa2b5d852514113b1aec11bdda637f23c7c15cb26",
	"0x53ba6359a9388dbc1f71abafaacc3f1943711cb6",
	"0x6519e03a19525241dca11e4b5681912230ef03e7",
	"0x7725a3caf343470f7d8b09ce7382a483e483aeca",
	"0x99526b337aea2ef72f454de80722c98bf216e6f9",
	"0x2e0ce5513f4b3a48a8a4e30ff69e24714f5cd5fa",
	"0x153685a03c2025b6825ae164e2ff5681ee487667",
	"0x79942da7a05500722b271e82fd895e3ba29289cc",
	"0xc93a9cab33975869e94f458ce590de4643d102c4",
	"0x9b3319caa84a3dba6be70df1eb7af3ca413f8eb1",
	"0xc3c519cdf6a7c0b2f5733c460e1a28208976d83d",
	"0xdf2350f4147e59d79a144045d03bb4ca34987c2f",
	"0x581b3d2cdcd3911d9bbf503550c3f6c1f3c997b1",
	"0x66a12b0086e0320f2e6e26c6ff93157c0c365cfb",
	"0x391a3ea52c4a9f04be6900c3fd057dd9676c72e1",
	"0x83bb781a2a2ca1fec0350f178c911848811cc440",
	"0x557d9c665c4dc7be280791869b68b15b41f72825",
	"0xf50e790c7061eb704cda1dc10b3ce5ab66df8499",
	"0x5977f1f284fd3bd05c2ad8680b100f9fa94952f5",
	"0x6841ccc222018ba65432d1f753676562d6c12f10",
	"0xdc59bdbf8a404a6663505cad3d40890f8aade79f",
	"0xde67adf51408acca6bee2abe20dbfff2dddfed33",
	"0xa823648a8251b44b09873723a32831f2f206acd5",
	"0x17d73b29c929cbe47a149626cd8d7504dbf8eca6",
	"0x5937e6c4e4d30717fd57a05f438b68b3ae2785d9",
	"0x6649a68ae781b9f51d50de2e9f609db2afdaae51",
	"0x7f3b29c4c425b9f040e1d7ee29e6b86e5fec393a",
	"0x180b99e223ac8e703282302edca2ded92d33581e",
	"0x1e915b59f0400f29dd974037b1672a572f664575",
	"0x39b3501de5ee7878bcc00bcb03035e3046e4c80f",
	"0x297683b64a416f2b105e776b88e8dc31e1114fa6",
	"0x6908be26d7aeb5d01d5775df4ccd80b704eaa455",
	"0x12a59989f8f06130bda8d6e936b2045c734f19ac",
	"0x05f2c11996d73288abe8a31d8b593a693ff2e5d8",
	"0x07c622e3a3c9eb73f02effee4cfc189897bff467",
	"0xaa53d3692800c300fb7c969399fd5df1cdd6f02e",
	"0x43501e11acf3dfdae4bd2ca40c5ea1303fc51941"
];

// Referral points tracker smart contract
const Tracker = artifacts.require("./RefPointsTracker.sol");

contract('RefPointsTracker: Gas Usage', (accounts) => {
	it("gas: deploying RefPointsTracker requires 1027454 gas", async() => {
		const tracker = await Tracker.new();
		const txHash = tracker.transactionHash;
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);
		const gasUsed = txReceipt.gasUsed;

		assertEqual(1027454, gasUsed, "deploying RefPointsTracker gas usage mismatch: " + gasUsed);
	});
	it("gas: issuing some ref points requires 88334 gas", async() => {
		const tracker = await Tracker.new();
		const gasUsed = (await tracker.issueTo(accounts[1], 1)).receipt.gasUsed;

		assertEqual(88334, gasUsed, "issuing some ref points gas usage mismatch: " + gasUsed);
	});
	it("gas: issuing some additional ref points requires 32743 gas", async() => {
		const tracker = await Tracker.new();
		await tracker.issueTo(accounts[1], 1);
		const gasUsed = (await tracker.issueTo(accounts[1], 1)).receipt.gasUsed;

		assertEqual(32743, gasUsed, "issuing some additional ref points gas usage mismatch: " + gasUsed);
	});
	it("gas: consuming some ref points requires 48564 gas", async() => {
		const tracker = await Tracker.new();
		await tracker.issueTo(accounts[1], 1);
		const gasUsed = (await tracker.consumeFrom(accounts[1], 1)).receipt.gasUsed;

		assertEqual(48564, gasUsed, "issuing some ref points gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk issuing ref points to 10 addresses requires 541112 gas", async() => {
		const tracker = await Tracker.new();
		const size = 10;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const points = new Array(size).fill(1);
		const gasUsed = (await tracker.bulkIssue(addresses, points)).receipt.gasUsed;

		assertEqual(541112, gasUsed, "bulk issuing ref points to 10 addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk issuing ref points to 20 addresses requires 1043675 gas", async() => {
		const tracker = await Tracker.new();
		const size = 20;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const points = new Array(size).fill(1);
		const gasUsed = (await tracker.bulkIssue(addresses, points)).receipt.gasUsed;

		assertEqual(1043675, gasUsed, "bulk issuing ref points to 20 addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk consuming ref points from 10 addresses requires 275936 gas", async() => {
		const tracker = await Tracker.new();
		const size = 10;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const points = new Array(size).fill(1);
		await tracker.bulkIssue(addresses, points);
		const gasUsed = (await tracker.bulkConsume(addresses, points)).receipt.gasUsed;

		assertEqual(275936, gasUsed, "bulk consuming ref points from 10 addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk consuming ref points from 20 addresses requires 528499 gas", async() => {
		const tracker = await Tracker.new();
		const size = 20;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const points = new Array(size).fill(1);
		await tracker.bulkIssue(addresses, points);
		const gasUsed = (await tracker.bulkConsume(addresses, points)).receipt.gasUsed;

		assertEqual(528499, gasUsed, "bulk consuming ref points from 20 addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk adding 10 known addresses requires 519451 gas", async() => {
		const tracker = await Tracker.new();
		const size = 10;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const gasUsed = (await tracker.bulkAddKnownAddresses(addresses)).receipt.gasUsed;

		assertEqual(519451, gasUsed, "bulk adding 10 known addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: bulk adding 20 known addresses requires 1009832 gas", async() => {
		const tracker = await Tracker.new();
		const size = 20;
		const addresses = Array.from(new Array(size), (x, i) => i + 1);
		const gasUsed = (await tracker.bulkAddKnownAddresses(addresses)).receipt.gasUsed;

		assertEqual(1009832, gasUsed, "bulk adding 20 known addresses gas usage mismatch: " + gasUsed);
	});
	it("gas: full deployment requires 1053609, 3538304, 1002596, 4072075, 4006885 gas", async() => {
		const tracker = await Tracker.new();
		const txHash = tracker.transactionHash;
		const txReceipt = await web3.eth.getTransactionReceipt(txHash);

		// referral points tracker deployment cost
		const gasUsed0 = txReceipt.gasUsed;

		// cost of adding issued referral points data
		const gasUsed1 = (await tracker.bulkIssue(addresses_issued, points_issued)).receipt.gasUsed;

		// cost of adding consumed referral points data
		const gasUsed2 = (await tracker.bulkConsume(addresses_consumed, points_consumed)).receipt.gasUsed;

		// cost of adding known addresses data, split into two transactions to fit into block (4500000)
		const gasUsed3 = (await tracker.bulkAddKnownAddresses(known_addresses.slice(0, 81))).receipt.gasUsed;
		const gasUsed4 = (await tracker.bulkAddKnownAddresses(known_addresses.slice(81))).receipt.gasUsed;

		console.log("\tdeployment:  " + gasUsed0);
		console.log("\tref_issue:   " + gasUsed1);
		console.log("\tref_consume: " + gasUsed2);
		console.log("\tadd_known_1: " + gasUsed3);
		console.log("\tadd_known_2: " + gasUsed4);

		// just verify costs doesn't exceed block size
		assert(gasUsed0 < 4500000, "referral points tracker deployment exceeds gas limit");
		assert(gasUsed1 < 4500000, "cost of adding issued referral points data exceeds gas limit");
		assert(gasUsed2 < 4500000, "cost of adding consumed referral points data exceeds gas limit");
		assert(gasUsed3 < 4500000, "cost of adding known addresses data (1) exceeds gas limit");
		assert(gasUsed4 < 4500000, "cost of adding known addresses data (2) exceeds gas limit");
	});
});


// asserts equal with precision of 5%
function assertEqual(expected, actual, msg) {
	assertEqualWith(expected, actual, 0.05, msg);
}

// asserts equal with the precisions defined in leeway
function assertEqualWith(expected, actual, leeway, msg) {
	assert(expected * (1 - leeway) < actual && expected * (1 + leeway) > actual, msg);
}
