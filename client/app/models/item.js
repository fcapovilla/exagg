import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  url: DS.attr('string'),
  guid: DS.attr('string'),
  content: DS.attr('string'),
  read: DS.attr('boolean'),
  favorite: DS.attr('boolean'),
  date: DS.attr('date'),
  origFeedTitle: DS.attr('string'),
  feed: DS.belongsTo('feed'),
});
