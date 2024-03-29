//
//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.17;
//
//interface IERC721Receiver {
//    function onERC721Received(
//        address operator,
//        address from,
//        uint tokenId,
//        bytes calldata data
//    ) external returns (bytes4);
//}
//
//interface INonfungiblePositionManager {
//    struct MintParams {
//        address token0;
//        address token1;
//        uint24 fee;
//        int24 tickLower;
//        int24 tickUpper;
//        uint amount0Desired;
//        uint amount1Desired;
//        uint amount0Min;
//        uint amount1Min;
//        address recipient;
//        uint deadline;
//    }
//
//    function mint(
//        MintParams calldata params
//    )
//        external
//        payable
//        returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1);
//
//    struct IncreaseLiquidityParams {
//        uint tokenId;
//        uint amount0Desired;
//        uint amount1Desired;
//        uint amount0Min;
//        uint amount1Min;
//        uint deadline;
//    }
//
//    function increaseLiquidity(
//        IncreaseLiquidityParams calldata params
//    ) external payable returns (uint128 liquidity, uint amount0, uint amount1);
//
//    struct DecreaseLiquidityParams {
//        uint tokenId;
//        uint128 liquidity;
//        uint amount0Min;
//        uint amount1Min;
//        uint deadline;
//    }
//
//    function decreaseLiquidity(
//        DecreaseLiquidityParams calldata params
//    ) external payable returns (uint amount0, uint amount1);
//
//    struct CollectParams {
//        uint tokenId;
//        address recipient;
//        uint128 amount0Max;
//        uint128 amount1Max;
//    }
//
//    function collect(
//        CollectParams calldata params
//    ) external payable returns (uint amount0, uint amount1);
//}
//
//interface IERC20 {
//    function totalSupply() external view returns (uint);
//
//    function balanceOf(address account) external view returns (uint);
//
//    function transfer(address recipient, uint amount) external returns (bool);
//
//    function allowance(address owner, address spender) external view returns (uint);
//
//    function approve(address spender, uint amount) external returns (bool);
//
//    function transferFrom(
//        address sender,
//        address recipient,
//        uint amount
//    ) external returns (bool);
//
//    event Transfer(address indexed from, address indexed to, uint value);
//    event Approval(address indexed owner, address indexed spender, uint value);
//}
//
//interface IWETH is IERC20 {
//    function deposit() external payable;
//
//    function withdraw(uint amount) external;
//}
//
//contract AddLPSwapV3 is IERC721Receiver {
//
//    int24 private constant MIN_TICK = -887272;
//    int24 private constant MAX_TICK = -MIN_TICK;
//    int24 private constant TICK_SPACING = 60;
//
//    INonfungiblePositionManager public nonfungiblePositionManager =
//        INonfungiblePositionManager(0x46A15B0b27311cedF172AB29E4f4766fbE7F4364);
//
//    function onERC721Received(
//        address operator,
//        address from,
//        uint tokenId,
//        bytes calldata
//    ) external returns (bytes4) {
//        return IERC721Receiver.onERC721Received.selector;
//    }
//
//    function mintNewPosition(
//        address _baseToken,
//        address _tokenB,
//        uint amount0ToAdd,
//        uint amount1ToAdd
//    ) external returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1) {
//
//        IERC20(_baseToken).approve(address(nonfungiblePositionManager), amount0ToAdd);
//        IERC20(_tokenB).approve(address(nonfungiblePositionManager), amount1ToAdd);
//
//        INonfungiblePositionManager.MintParams
//            memory params = INonfungiblePositionManager.MintParams({
//                token0: _baseToken,
//                token1: _tokenB,
//                fee: 3000,
//                tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
//                tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
//                amount0Desired: amount0ToAdd,
//                amount1Desired: amount1ToAdd,
//                amount0Min: 0,
//                amount1Min: 0,
//                recipient: msg.sender,
//                deadline: block.timestamp
//            });
//
//        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(
//            params
//        );
//
//        if (amount0 < amount0ToAdd) {
//            IERC20(_baseToken).approve(address(nonfungiblePositionManager), 0);
//            uint refund0 = amount0ToAdd - amount0;
//            IERC20(_baseToken).transfer(msg.sender, refund0);
//        }
//        if (amount1 < amount1ToAdd) {
//            IERC20(_tokenB).approve(address(nonfungiblePositionManager), 0);
//            uint refund1 = amount1ToAdd - amount1;
//            IERC20(_tokenB).transfer(msg.sender, refund1);
//        }
//    }
//
//    function collectAllFees(
//        uint tokenId
//    ) external returns (uint amount0, uint amount1) {
//        INonfungiblePositionManager.CollectParams
//            memory params = INonfungiblePositionManager.CollectParams({
//                tokenId: tokenId,
//                recipient: msg.sender,
//                amount0Max: type(uint128).max,
//                amount1Max: type(uint128).max
//            });
//
//        (amount0, amount1) = nonfungiblePositionManager.collect(params);
//    }
//
//    function increaseLiquidityCurrentRange(
//        address _baseToken,
//        address _tokenB,
//        uint tokenId,
//        uint amount0ToAdd,
//        uint amount1ToAdd
//    ) external returns (uint128 liquidity, uint amount0, uint amount1) {
//
//        IERC20(_baseToken).approve(address(nonfungiblePositionManager), amount0ToAdd);
//        IERC20(_tokenB).approve(address(nonfungiblePositionManager), amount1ToAdd);
//
//        INonfungiblePositionManager.IncreaseLiquidityParams
//            memory params = INonfungiblePositionManager.IncreaseLiquidityParams({
//                tokenId: tokenId,
//                amount0Desired: amount0ToAdd,
//                amount1Desired: amount1ToAdd,
//                amount0Min: 0,
//                amount1Min: 0,
//                deadline: block.timestamp
//            });
//
//        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(
//            params
//        );
//    }
//
//    function decreaseLiquidityCurrentRange(
//        uint tokenId,
//        uint128 liquidity
//    ) external returns (uint amount0, uint amount1) {
//        INonfungiblePositionManager.DecreaseLiquidityParams
//            memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
//                tokenId: tokenId,
//                liquidity: liquidity,
//                amount0Min: 0,
//                amount1Min: 0,
//                deadline: block.timestamp
//            });
//
//        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
//    }
//}
