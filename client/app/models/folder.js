import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  open: DS.attr('boolean'),
  position: DS.attr('number'),
  feeds: DS.hasMany('feed', {async: true}),
  items: DS.hasMany('item', {async: true})
});
