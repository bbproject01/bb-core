// // SPDX-License-Identifier: GPL-3.0-or-later
// pragma solidity 0.8.20;

// import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
// import '@openzeppelin/contracts/utils/math/SafeMath.sol';
// import '@openzeppelin/contracts/access/Ownable.sol';

// /**
//  * @title BBTOKEN
//  * @dev Contrato de token personalizado BBTOKEN que cumple con el estándar ERC20.
//  * Implementa las interfaces IERC20 e IERC20Metadata.
//  * Incluye funcionalidades básicas de transferencia, aprobación y quema de tokens.
//  * Además, el contrato permite la emisión de nuevos tokens por el propietario y puede tener un límite máximo de suministro.
//  */
// contract BBTOKEN is IERC20, IERC20Metadata, Ownable {
//   using SafeMath for uint256;

//   mapping(address => uint256) private _balances;
//   mapping(address => mapping(address => uint256)) private _allowances;

//   string private _name;
//   string private _symbol;
//   uint8 private _decimals;
//   uint256 private _totalSupply;

//   uint256 private _maxSupply;
//   bool private _maxSupplyEnabled;

//   /**
//    * @dev Crea el contrato BBTOKEN.
//    * @param name_ El nombre del token.
//    * @param symbol_ El símbolo del token.
//    * @param decimals_ El número de decimales del token.
//    * @param totalSupply_ La cantidad total de tokens en circulación.
//    * @param maxSupply_ La cantidad máxima de tokens permitidos.
//    */
//   constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_, uint256 maxSupply_) {
//     _name = name_;
//     _symbol = symbol_;
//     _decimals = decimals_;
//     _totalSupply = totalSupply_.mul(10 ** decimals_);
//     _maxSupply = maxSupply_.mul(10 ** decimals_);
//     _balances[msg.sender] = _totalSupply;
//     _maxSupplyEnabled = true;
//     emit Transfer(address(0), msg.sender, _totalSupply);
//   }

//   /**
//    * @dev Devuelve el nombre del token.
//    * @return El nombre del token.
//    */
//   function name() public view override returns (string memory) {
//     return _name;
//   }

//   /**
//    * @dev Devuelve el símbolo del token.
//    * @return El símbolo del token.
//    */
//   function symbol() public view override returns (string memory) {
//     return _symbol;
//   }

//   /**
//    * @dev Devuelve el número de decimales del token.
//    * @return El número de decimales del token.
//    */
//   function decimals() public view override returns (uint8) {
//     return _decimals;
//   }

//   /**
//    * @dev Devuelve la cantidad total de tokens en circulación.
//    * @return La cantidad total de tokens en circulación.
//    */
//   function totalSupply() public view override returns (uint256) {
//     return _totalSupply;
//   }

//   /**
//    * @dev Devuelve el saldo de tokens de una dirección específica.
//    * @param account La dirección para la cual se consulta el saldo.
//    * @return El saldo de tokens de la dirección especificada.
//    */
//   function balanceOf(address account) public view override returns (uint256) {
//     return _balances[account];
//   }

//   /**
//    * @dev Transfiere una cantidad de tokens a una dirección específica.
//    * @param recipient La dirección del destinatario de los tokens.
//    * @param amount La cantidad de tokens a transferir.
//    * @return true si la transferencia se realiza con éxito, de lo contrario, false.
//    */
//   function transfer(address recipient, uint256 amount) public override returns (bool) {
//     _transfer(msg.sender, recipient, amount);
//     return true;
//   }

//   /**
//    * @dev Devuelve la cantidad de tokens que el propietario ha permitido que se gasten por parte de una dirección específica.
//    * @param owner La dirección del propietario de los tokens.
//    * @param spender La dirección que está autorizada a gastar los tokens.
//    * @return La cantidad de tokens permitidos.
//    */
//   function allowance(address owner, address spender) public view override returns (uint256) {
//     return _allowances[owner][spender];
//   }

//   /**
//    * @dev Permite que una dirección gaste una cantidad de tokens en nombre del propietario.
//    * @param spender La dirección autorizada para gastar los tokens.
//    * @param amount La cantidad de tokens que se permitirán gastar.
//    * @return Éxito de la aprobación.
//    */
//   function approve(address spender, uint256 amount) public override returns (bool) {
//     _approve(msg.sender, spender, amount);
//     return true;
//   }

//   /**
//    * @dev Transfiere tokens de una dirección a otra.
//    * @param sender La dirección del remitente.
//    * @param recipient La dirección del receptor.
//    * @param amount La cantidad de tokens a transferir.
//    * @return Éxito de la transferencia.
//    */
//   function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
//     _transfer(sender, recipient, amount);
//     _approve(
//       sender,
//       msg.sender,
//       _allowances[sender][msg.sender].sub(amount, 'ERC20: transfer amount exceeds allowance')
//     );
//     return true;
//   }

//   /**
//    * @dev Aumenta la cantidad de tokens que una dirección puede gastar en nombre del propietario.
//    * @param spender La dirección autorizada para gastar los tokens.
//    * @param addedValue La cantidad adicional de tokens a permitir gastar.
//    * @return Éxito de la operación.
//    */
//   function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
//     _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
//     return true;
//   }

//   /**
//    * @dev Disminuye la cantidad de tokens que una dirección puede gastar en nombre del propietario.
//    * @param spender La dirección autorizada para gastar los tokens.
//    * @param subtractedValue La cantidad de tokens a reducir de la asignación actual.
//    * @return Éxito de la operación.
//    */
//   function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
//     _approve(
//       msg.sender,
//       spender,
//       _allowances[msg.sender][spender].sub(subtractedValue, 'ERC20: decreased allowance below zero')
//     );
//     return true;
//   }

//   /**
//    * @dev Crea nuevos tokens y los asigna a una cuenta específica.
//    * @param account La dirección a la que se asignarán los nuevos tokens.
//    * @param amount La cantidad de tokens a crear y asignar.
//    */

//   function mint(address account, uint256 amount) public onlyOwner {
//     require(_maxSupplyEnabled == true, 'ERC20: max supply reached');
//     require(_totalSupply.add(amount) <= _maxSupply, 'ERC20: max supply exceeded');
//     _totalSupply = _totalSupply.add(amount);
//     _balances[account] = _balances[account].add(amount);
//     emit Transfer(address(0), account, amount);
//   }

//   /**
//    * @dev Quema una cantidad de tokens del saldo del remitente.
//    * @param amount La cantidad de tokens a quemar.
//    */
//   function burn(uint256 amount) public {
//     _burn(msg.sender, amount);
//   }

//   /**
//    * @dev Quema una cantidad de tokens de la cuenta de una dirección específica.
//    * @param account La dirección de la cuenta desde donde se quemarán los tokens.
//    * @param amount La cantidad de tokens a quemar.
//    */
//   function burnFrom(address account, uint256 amount) public {
//     uint256 decreasedAllowance = _allowances[account][msg.sender].sub(amount, 'ERC20: burn amount exceeds allowance');
//     _approve(account, msg.sender, decreasedAllowance);
//     _burn(account, amount);
//   }

//   /**
//    * @dev Desactiva el límite máximo de suministro de tokens.
//    * Solo puede ser llamado por el propietario del contrato.
//    */
//   function disableMaxSupply() public onlyOwner {
//     _maxSupplyEnabled = false;
//   }

//   /**
//    * @dev Activa el límite máximo de suministro de tokens.
//    * Solo puede ser llamado por el propietario del contrato.
//    */
//   function enableMaxSupply() public onlyOwner {
//     _maxSupplyEnabled = true;
//   }

//   /**
//    * @dev Transfiere tokens de una dirección a otra.
//    * @param sender La dirección del remitente.
//    * @param recipient La dirección del receptor.
//    * @param amount La cantidad de tokens a transferir.
//    */
//   function _transfer(address sender, address recipient, uint256 amount) internal {
//     require(sender != address(0), 'ERC20: transfer from the zero address');
//     require(recipient != address(0), 'ERC20: transfer to the zero address');
//     require(_balances[sender] >= amount, 'ERC20: insufficient balance');

//     _balances[sender] = _balances[sender].sub(amount);
//     _balances[recipient] = _balances[recipient].add(amount);
//     emit Transfer(sender, recipient, amount);
//   }

//   /**
//    * @dev Establece la cantidad de tokens que una dirección autorizada puede gastar en nombre del propietario.
//    * @param owner La dirección del propietario de los tokens.
//    * @param spender La dirección autorizada para gastar los tokens.
//    * @param amount La cantidad de tokens a permitir gastar.
//    */
//   function _approve(address owner, address spender, uint256 amount) internal {
//     require(owner != address(0), 'ERC20: approve from the zero address');
//     require(spender != address(0), 'ERC20: approve to the zero address');

//     _allowances[owner][spender] = amount;
//     emit Approval(owner, spender, amount);
//   }

//   /**
//    * @dev Quema una cantidad de tokens del saldo de una cuenta específica.
//    * @param account La dirección de la cuenta desde donde se quemarán los tokens.
//    * @param amount La cantidad de tokens a quemar.
//    */
//   function _burn(address account, uint256 amount) internal {
//     require(account != address(0), 'ERC20: burn from the zero address');
//     require(_balances[account] >= amount, 'ERC20: insufficient balance for burning');

//     _balances[account] = _balances[account].sub(amount);
//     _totalSupply = _totalSupply.sub(amount);
//     emit Transfer(account, address(0), amount);
//   }
// }
