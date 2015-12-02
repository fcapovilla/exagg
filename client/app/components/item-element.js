import Ember from 'ember';
import momentFormat from 'ember-moment/computeds/format';

export default Ember.Component.extend({
  tagName: 'li',

  formattedDate: momentFormat('model.date', 'DD/MM/YYYY hh:mm'),

  actions: {
    toggleFavorite() {
      this.model.set('favorite', !this.model.get('favorite'));
      this.model.save();
    },

    toggleRead() {
      this.model.set('read', !this.model.get('read'));
      this.model.save();
    },

    toggleOpen() {
      if(this.model.get('open')) {
        this.sendAction('onSelect', null);
      }
      else {
        this.sendAction('onSelect', this.model);
      }
    },
  }
});
