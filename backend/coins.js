const coins = [
  {
    id: "bitcoin",
    symbol: "BTC",
    name: "Bitcoin",
    price: 67432.50,
    change24h: 2.34,
    marketCap: "1.32T",
    volume: "28.4B",
    description: "Bitcoin is the first and most well-known cryptocurrency. Created in 2009 by the anonymous Satoshi Nakamoto, it introduced blockchain technology to the world and remains the gold standard of digital assets.",
    color: "#F7931A"
  },
  {
    id: "ethereum",
    symbol: "ETH",
    name: "Ethereum",
    price: 3521.80,
    change24h: 1.87,
    marketCap: "423.1B",
    volume: "14.2B",
    description: "Ethereum is a decentralized platform that enables smart contracts and decentralized applications. It introduced programmable blockchain, making it the foundation for DeFi and NFTs.",
    color: "#627EEA"
  },
  {
    id: "solana",
    symbol: "SOL",
    name: "Solana",
    price: 178.45,
    change24h: -1.23,
    marketCap: "82.3B",
    volume: "3.8B",
    description: "Solana is a high-performance blockchain supporting fast transactions and low fees. Known for its speed and efficiency, it has become a popular platform for DeFi and NFT projects.",
    color: "#9945FF"
  },
  {
    id: "binancecoin",
    symbol: "BNB",
    name: "BNB",
    price: 412.30,
    change24h: 0.95,
    marketCap: "61.2B",
    volume: "1.9B",
    description: "BNB is the native token of the Binance ecosystem. Originally created as a utility token for the Binance exchange, it now powers the BNB Chain and is used for transaction fees and DeFi.",
    color: "#F3BA2F"
  },
  {
    id: "cardano",
    symbol: "ADA",
    name: "Cardano",
    price: 0.4823,
    change24h: -2.10,
    marketCap: "17.1B",
    volume: "412.5M",
    description: "Cardano is a proof-of-stake blockchain platform founded on peer-reviewed research. It aims to provide a more secure and sustainable infrastructure for DeFi applications.",
    color: "#0033AD"
  },
  {
    id: "ripple",
    symbol: "XRP",
    name: "XRP",
    price: 0.5912,
    change24h: 3.45,
    marketCap: "32.8B",
    volume: "1.2B",
    description: "XRP is designed for fast and low-cost international money transfers. It serves as a bridge currency in Ripple's payment network, enabling banks and financial institutions to settle transactions instantly.",
    color: "#00AAE4"
  },
  {
    id: "polkadot",
    symbol: "DOT",
    name: "Polkadot",
    price: 7.823,
    change24h: 1.12,
    marketCap: "11.2B",
    volume: "289.4M",
    description: "Polkadot enables different blockchains to transfer messages and value in a trust-free fashion. It aims to create a fully decentralized web where users are in control.",
    color: "#E6007A"
  },
  {
    id: "dogecoin",
    symbol: "DOGE",
    name: "Dogecoin",
    price: 0.1634,
    change24h: 5.67,
    marketCap: "23.4B",
    volume: "1.8B",
    description: "Dogecoin started as a meme but became one of the most recognized cryptocurrencies. With a passionate community and celebrity endorsements, it remains a popular choice for tipping and microtransactions.",
    color: "#C2A633"
  },
  {
    id: "avalanche",
    symbol: "AVAX",
    name: "Avalanche",
    price: 38.92,
    change24h: -0.78,
    marketCap: "16.1B",
    volume: "432.1M",
    description: "Avalanche is a layer-1 blockchain platform known for its speed and low transaction costs. It supports the creation of custom blockchain networks and is a growing hub for DeFi applications.",
    color: "#E84142"
  },
  {
    id: "chainlink",
    symbol: "LINK",
    name: "Chainlink",
    price: 14.23,
    change24h: 2.89,
    marketCap: "8.4B",
    volume: "312.8M",
    description: "Chainlink is a decentralized oracle network that connects smart contracts with real-world data. It is the leading solution for bringing off-chain information onto the blockchain securely.",
    color: "#2A5ADA"
  },
  {
    id: "litecoin",
    symbol: "LTC",
    name: "Litecoin",
    price: 84.56,
    change24h: 0.34,
    marketCap: "6.3B",
    volume: "198.4M",
    description: "Litecoin is one of the earliest cryptocurrencies after Bitcoin. Often called the silver to Bitcoin's gold, it offers faster transaction confirmation times and a different hashing algorithm.",
    color: "#BFBBBB"
  },
  {
    id: "stellar",
    symbol: "XLM",
    name: "Stellar",
    price: 0.1245,
    change24h: 1.56,
    marketCap: "3.6B",
    volume: "89.3M",
    description: "Stellar is an open network for storing and moving money. It is designed to connect financial institutions and reduce the cost of cross-border transfers, especially in developing markets.",
    color: "#7D00FF"
  },
  {
    id: "uniswap",
    symbol: "UNI",
    name: "Uniswap",
    price: 9.34,
    change24h: -1.45,
    marketCap: "5.6B",
    volume: "143.2M",
    description: "Uniswap is the leading decentralized exchange protocol on Ethereum. It allows users to swap ERC-20 tokens directly from their wallets without a centralized intermediary.",
    color: "#FF007A"
  },
  {
    id: "tron",
    symbol: "TRX",
    name: "TRON",
    price: 0.1189,
    change24h: 0.67,
    marketCap: "10.4B",
    volume: "312.1M",
    description: "TRON is a blockchain platform focused on entertainment and content sharing. It aims to decentralize the internet by allowing creators to connect directly with consumers.",
    color: "#FF0013"
  },
  {
    id: "cosmos",
    symbol: "ATOM",
    name: "Cosmos",
    price: 8.92,
    change24h: 2.13,
    marketCap: "3.5B",
    volume: "98.4M",
    description: "Cosmos is an ecosystem of interoperable blockchains. Known as the internet of blockchains, it enables different blockchain networks to communicate and exchange value with each other.",
    color: "#2E3148"
  },
  {
    id: "near",
    symbol: "NEAR",
    name: "NEAR Protocol",
    price: 6.78,
    change24h: 3.21,
    marketCap: "7.4B",
    volume: "213.4M",
    description: "NEAR Protocol is a developer-friendly blockchain platform designed for decentralized applications. It uses a unique sharding mechanism called Nightshade to achieve high throughput.",
    color: "#00C08B"
  },
  {
    id: "aptos",
    symbol: "APT",
    name: "Aptos",
    price: 9.12,
    change24h: -3.45,
    marketCap: "3.8B",
    volume: "189.3M",
    description: "Aptos is a next-generation layer-1 blockchain built by former Meta engineers. It uses the Move programming language and is designed for safety, scalability and upgradability.",
    color: "#00D4AA"
  },
  {
    id: "internetcomputer",
    symbol: "ICP",
    name: "Internet Computer",
    price: 12.34,
    change24h: 1.89,
    marketCap: "5.8B",
    volume: "98.3M",
    description: "Internet Computer is a blockchain that runs at web speed with unbounded capacity. Developed by DFINITY, it aims to host the entire internet in a decentralized manner.",
    color: "#29ABE2"
  },
  {
    id: "vechain",
    symbol: "VET",
    name: "VeChain",
    price: 0.0389,
    change24h: 0.45,
    marketCap: "2.8B",
    volume: "67.4M",
    description: "VeChain is a blockchain platform designed for supply chain management and business processes. It helps companies track products and verify authenticity using blockchain technology.",
    color: "#15BDFF"
  },
  {
    id: "algorand",
    symbol: "ALGO",
    name: "Algorand",
    price: 0.1923,
    change24h: -0.89,
    marketCap: "1.6B",
    volume: "43.2M",
    description: "Algorand is a self-sustaining, decentralized blockchain network. Founded by MIT professor Silvio Micali, it aims to solve the blockchain trilemma of security, scalability and decentralization.",
    color: "#000000"
  }
];

module.exports = coins;