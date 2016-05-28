import Ember from 'ember';
import momentFormat from 'ember-moment/computeds/format';

export default Ember.Component.extend({
  tagName: 'li',

  formattedDate: momentFormat('model.date', 'DD/MM/YYYY HH:mm'),

  openChanged: Ember.observer('model.open', function() {
    if(this.model.get('open')) {
      Ember.run.scheduleOnce('afterRender', this, function() {
        var elem = this.$(this.get('element'));
        var list = Ember.$('#item-list').eq(0);
        list.scrollTop(elem.position().top + list.scrollTop());
      });
    }
  }),

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
