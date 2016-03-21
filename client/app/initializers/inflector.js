import Ember from 'ember';

export function initialize(/* application */) {
    var inflector = Ember.Inflector.inflector;

    inflector.uncountable('media');
}

export default {
  name: 'inflector',
  initialize
};
