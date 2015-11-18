import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  url: DS.attr('string'),
  lastSync: DS.attr('date'),
  unreadCount: DS.attr('number'),
  syncStatus: DS.attr('string'),
  favicon: DS.attr('string'),
  position: DS.attr('number'),

  items: DS.hasMany('item', {async: true}),
  folder: DS.belongsTo('folder')
});
