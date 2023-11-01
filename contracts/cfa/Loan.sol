// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.17;

// import '@openzeppelin/contracts/access/Ownable.sol';
// import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
// import './interface/IInsurance.sol';
// import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
// import '../utils/Registry.sol';
// import '../token/BBTOKENv2.sol';

// contract Loan is Ownable, ReentrancyGuard, IInsurance, Registry, {

// mapping(uint256 => uint256) public loanBalance;

//   function createLoan(uint256 _id) external nonReentrant {
//        require(balanceOf(msg.sender, _id) == 1, 'Insurance: invalid id');
//        require(!attributes[_id].loan, 'Insurance: Loan already created');

//       (uint256 interest, uint256 principal) = getInterest(_id);
//       uint256 loanedPrincipal = ((principal + interest) * 25) / 100;

//       BBToken token = BBToken(registry.registry('BbToken'));
//       uint256 totalLoan = interest + loanedPrincipal;

//       token.mint(msg.sender, totalLoan); 
      
//     //   attributes[_id].loan = true;
//       loanBalance[_id] = totalLoan;
      
//   }

//     function repayLoan(uint256 _id, uint256 _amount) external payable nonReentrant {
//     //   require(attributes[_id].loan, 'Insurance: Loan invalid');
//     //   require(_amount <= loanBalance[_id], 'Insurance: Incorrect loan repayment amount');
      
//       if(_amount < loanBalance[_id]){
//       uint256 _loanBalance = loanBalance[_id];
//       loanBalance[_id] = _loanBalance - _amount;
//       }
      
//       BBToken token = BBToken(registry.registry('BbToken'));
//       token.burn(_amount); 

//     //  attributes[_id].loan = false;
//       loanBalance[_id] = 0;

// }

// function getLoanBalance(uint _id) public view returns (uint) {
//     uint _loanBalance = loanBalance[_id];
//     return _loanBalance;
// }
// }