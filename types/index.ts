import { Signer } from "@ethersproject/abstract-signer";

export interface Accounts {
  deployer: string;
}

export interface Signers {
  deployer: Signer;
}
