import Qux from 'test_engine/qux';

function Baz(config) {
  this.qux = new Qux(config.qux);
}

export default Baz;
