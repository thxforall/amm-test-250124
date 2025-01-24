const { buildModule } = require('@nomicfoundation/hardhat-ignition/modules');

module.exports = buildModule('CPMMDeployment', (m) => {
  // Test1CPMM 배포
  const test1CPMM = m.contract('Test1CPMM', {
    args: ['AToken', 'BToken'],
  });

  // Test2CPMM 배포
  const test2CPMM = m.contract('Test2CPMM', {
    args: ['AToken', 'BToken'],
  });

  return { test1CPMM, test2CPMM };
});
