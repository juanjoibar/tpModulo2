# 🧾 Auction Smart Contract (Subasta)

This smart contract allows users to participate in a simple auction. It supports multiple offers, automatic time extensions, and partial refunds for non-winning bidders.

## 📌 Features

- Auction with a minimum starting value.
- Bids must increase at least by a percentage (`saltoBid`).
- Auction time is extended if a bid is placed near the deadline.
- Keeps track of all bidders and their balances.
- Refunds non-winning bidders (minus a 2% commission).
- Allows partial refunds if outbid before the auction ends.
- Events for new bids and auction end.

---

## 📂 Contract Overview

### 🔐 Variables

| Variable | Type | Description |
|---------|------|-------------|
| `flagEndBid` | `uint8` | Flag to indicate if the auction ended (1 = ended). |
| `valueMin` | `uint256` | Minimum bid value (default: 1 gwei). |
| `saltoBid` | `uint256` | Minimum percentage increase required to outbid. |
| `bidDuracion` | `uint256` | Auction end timestamp. |
| `extenbidTime` | `uint256` | Time extension if a bid is placed near the end. |
| `maxOfferta` | `uint256` | Current highest bid. |
| `winBidder` | `address` | Address of the highest bidder. |
| `owner` | `address` | Contract owner. |
| `offers` | `offer[]` | Array of all offers made. |
| `uniqueAddr` | `address[]` | Unique bidder addresses. |
| `balance` | `mapping` | ETH balance of each bidder. |

---

### 📤 Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `Newoffer` | `address bidder, uint256 amount, uint256 timestamp` | Emitted on each new valid offer. |
| `BidEnding` | `address bidder, uint256 amount` | Emitted when the auction ends. |

---

### ⚙️ Functions

#### Public / External

- `setOffer()`  
  Places a new bid. Must be at least 5% higher than the current max offer.  
  If called within the last 10 minutes of the auction, extends time.

- `getWin() → (address, uint256)`  
  Returns the winner and the amount of the highest offer.

- `getOffers() → offer[]`  
  Returns the full list of offers and bidders.

- `returnParcial()`  
  Allows a bidder to withdraw the surplus of their previous bid (if outbid).

#### Owner Only

- `endSubasta()`  
  Finalizes the auction and emits the winner.

- `returnOffers()`  
  Refunds all non-winning bidders with a 2% commission deducted. Remaining balance goes to the contract owner.

---

### 📦 Structs

```solidity
struct offer {
    address bidder;
    uint256 amount;
    uint256 offerDate;
}