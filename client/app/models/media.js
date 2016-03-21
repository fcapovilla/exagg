import DS from 'ember-data';
import Ember from 'ember';

Ember.Inflector.inflector.uncountable('media');

export default DS.Model.extend({
  url: DS.attr('string'),
  type: DS.attr('string'),
  item: DS.belongsTo('item', {async: true})
});
