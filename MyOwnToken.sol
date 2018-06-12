pragma solidity ^0.4.18; 
// ----------------------------------------------------------------------------
// '이더리움 토큰 5분만에 만들기
//  주의 256바이트 넘어갈수 없음! 
// Deployed to : 0x5Fe94E454eB5a3926a3050fdBE6d0f06090fA603
// 심볼(Symbol)  : HWDC
// 코인이름(Name) : Hello World token
// 총통화량(Total supply): 10000000   통화량만들기
// 총자릿수(소숫점이하,Decimals)    : 18
//
// 이더리움 코인을 쉽게 만들어 보자!  
// 여기서 바꿀것은, 심볼 코인이름, 총통화량dla~ 이것만 바꾸면, 나만의 코인 완성~~ 
// 참 쉽죠잉~~
// 참고로, 정수오버플로우 버그를 만들어 내는, BatchTransfer란 놈이 있는데
// 누군가 잘 정리해놨다. 그래서 링크.. https://www.clien.net/service/board/cm_vcoin/12030713
//  (c)제왕 알렉산더
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// SafeMath란 놈을 정의해야돼.. 
// 안전한 코인 사칙연산방법이지..
// 무한복사버그 막으려면 이방법 써야지~
// ----------------------------------------------------------------------------
contract SafeMath{
function safeAdd(uint a, uint b) public pure returns (uint c) {
c = a + b;
require(c >= a);
}
function safeSub(uint a, uint b) public pure returns (uint c) {
require(b <= a);
c = a - b; 
// 256byte uint 1.157920892373162e+77  해당범위를 넘어가면, 원래는 정수오버플로우 에러가 나서.

}
function safeMul(uint a, uint b) public pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b); 
// 나중에 추가 기능으로, 곱하기 연산을 실행하는 것들을 만들려고, 정의해놨지만, 사실 지갑기능에서 쓸데가 없어
//포인트 지급이나 이자계산등 혹은 각종 배치(여러명을 동일하게 처리하거나할때)작업에 활용될수 있어.
}
function safeDiv(uint a, uint b) public pure returns (uint c) {
require(b > 0);
c = a / b; 
// 곱하기연산과 같다고 보면돼.. 나누기와 곱하기는 한세트이니까..
}
}
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface

// 도 불러서 사용하고..
// ----------------------------------------------------------------------------
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
// ----------------------------------------------------------------------------
// 코인을 받았을때, 자동으로 실행해주는 건데.. 내가 코인받을때마다 확인하면 귀찬잖아~~
// 콜.. 마치 전화하게돼면, 받자마자 실행해.. 콜에대한 백.. 반응이야.
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
// ----------------------------------------------------------------------------
// 계약의 주인. 주소값이라고 할수 있잖아.. 결국 사람이 돈받는게 아니고, 
// 주소값이 받게 될테니 말이지~~
// 이때, address라는 이더에서 만든 타입명으로 정의하는 거야
// 
// 계약의 주인의 정보 변경하는 것이 바로 자신밖에 할수 없도록 처리하는 것도 잊지마
//  
// ----------------------------------------------------------------------------
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = msg.sender;
} 

//계약의 변경은 주인이 가능하다는 이야기야
// 여기서 계약은, 일방적인 계약이라는 이야기가 되는 거지.. 계약은 2인이상이 하는데 말이야~
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
// ----------------------------------------------------------------------------
// 이제 E18Token이라는 진짜 스마트(?)계약을 만들어 보자
// ERC20Interface, Owned, SafeMath로 구성되어 있다는 이야기야.
// 사실 토큰을 만드는거니까.. 별다른 변경없이 코인명, 코인발행량만 정의해주면 돼
// 물론, 보다 복잡하게 만들고 할수도 있지만, 잊지말라고, 256바이트를 넘어가면 안돼!!
// 무거운 코드일수록, 수수료도 비싸다고^^
// 주석이나 공백등은 컴파일하면서 사라지니까.. 주석은 길어도 상관없어~
// ----------------------------------------------------------------------------
contract HelloWorldToken  is ERC20Interface, Owned, SafeMath
 {
string public symbol;
string public name;
uint8 public decimals;
uint public _totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
// ------------------------------------------------------------------------
// Constructor 
// 변경해줄 부분임!!!!
// ------------------------------------------------------------------------
function HelloWorldToken() public {
symbol = "HWDC";
name = "Hello World Tokens";
decimals = 18;
_totalSupply = 10000000000000000000000000;
balances[0x5Fe94E454eB5a3926a3050fdBE6d0f06090fA603] = _totalSupply;
Transfer(address(0),0x5Fe94E454eB5a3926a3050fdBE6d0f06090fA603, _totalSupply);
}
// ------------------------------------------------------------------------
// 총공급량의 잔량!! 
// ------------------------------------------------------------------------
function totalSupply() public constant returns (uint) {
return _totalSupply - balances[address(0)];
}
// ------------------------------------------------------------------------
// 유저의 토큰양 확인하기
// ------------------------------------------------------------------------
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
// ------------------------------------------------------------------------
// 토근 넘겨주기
// 토큰 주인은 충분히 코인을 가지고 있어야 하고
// 0토큰은 전달이 가능하다.
// ------------------------------------------------------------------------
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = safeSub(balances[msg.sender], tokens);  //보내는사람으로부터 빼주고

balances[to] = safeAdd(balances[to], tokens); //받는사람에게 더해주고
Transfer(msg.sender, to, tokens);
return true;
}
// ------------------------------------------------------------------------
// 더블스펜딩을 방지하기위해서

// 토큰소유자가 승인해주는 과정
// ------------------------------------------------------------------------
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
return true;
}
// ------------------------------------------------------------------------
// 어카운트에서 어카운트로 전달하기 , 나중에 웹지갑을 만들때, rpc를 이용하게 되는데
// 이때, 어카운트로 주소값을 지정할수가 있고, 이때 계정에서 계정으로 토큰을 보낼수 있게 해주지

//---------------------------------
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = safeSub(balances[from], tokens);
allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
balances[to] = safeAdd(balances[to], tokens);
Transfer(from, to, tokens);
return true;
}
// ------------------------------------------------------------------------
// 어카운트에서 어카운트로 전달할때, 토큰오너가 승인하는 과정
// ------------------------------------------------------------------------
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
// ------------------------------------------------------------------------

// 이렇게 계약의 주인이 승인을 하면, 전화처럼 콜을 때리지, 그 콜은 받는 측은 자동으로 승인을 하는 구조란 말이지
// ------------------------------------------------------------------------
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
}
// ------------------------------------------------------------------------
// 이더로 안받으려면 아래처럼 처리해야돼(이렇게 해야, 혹시 이더로 토큰을 받게되는 과정을 막을수 있다)
// ------------------------------------------------------------------------
function () public payable {
revert();
}
// ------------------------------------------------------------------------
// 사고가 나면, 내코인 어떻게해? 그때, 일단, 코인을 특정주소에 전달할수 있도록 처리해주지.
// ------------------------------------------------------------------------
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) { 
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}
