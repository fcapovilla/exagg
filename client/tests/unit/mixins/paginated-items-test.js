import Ember from 'ember';
import PaginatedItemsMixin from 'exagg/mixins/paginated-items';
import { module, test } from 'qunit';

module('Unit | Mixin | paginated items');

// Replace this with your real tests.
test('it works', function(assert) {
  let PaginatedItemsObject = Ember.Object.extend(PaginatedItemsMixin);
  let subject = PaginatedItemsObject.create();
  assert.ok(subject);
});
