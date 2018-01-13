/*
Copyright (C) 2017 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
IRC: olpe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of wht nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

Array.prototype.findById = function(id) {
  for (var i = 0; i < this.length; i++) {
    if (this[i].id === id) {
      return this[i];
    }
  }
  return false;
};

String.prototype.toHHMM = function() {
  var dur = parseFloat(this) * 60;
  var hours = Math.floor(dur / 60).toFixed(0);
  var minutes = (dur % 60).toFixed(0);
  return hours + ':' + helpers.pad(minutes);
};

var helpers = {
  formatTimerDuration: function(durationInMs) {
    return moment.utc(durationInMs).format('H[h] mm[min]')
  },

  formatDuration: function(durationInMs) {
    return moment.utc(durationInMs).format('H:mm');
  },

  momentAsMilliseconds: function(momentObj) {
    // Returns the a moment object as milliseconds
    // Note this is not the same as moment().milliseconds()
    var m = momentObj
    var ms = m.milliseconds() + 1000 * (m.seconds() + 60 * (m.minutes() + 60 * m.hours()));
    return ms
  },

  calcRoundToNearest: function(value) {
    var inMinutes = value * 60;
    inMinutes =
      Math.round(inMinutes / appState.roundToNearest) * appState.roundToNearest;
    return inMinutes / 60;
  },

  hourMinuteRoundToNearest: function(hour, minute) {
    var inHours = hour + minute / 60;
    inHours = calcRoundToNearest(inHours);
    var inMinutes = inHours * 60;

    return {
      hour: Math.floor(inMinutes / 60),
      minute: inMinutes % 60
    };
  },

  pad: function(n) {
    return ('0' + n).slice(-2);
  },

  dateToDbDateString: function(date) {
    if (date) {
      //YYYY-MM-DD
      var yyyy = date.getFullYear().toString();
      var mm = (date.getMonth() + 1).toString(); // getMonth() is zero-based
      var dd = date.getDate().toString();
      return yyyy + '-' + pad(mm) + '-' + pad(dd);
    }
  },

  formatDate: function(datestring) {
    var d = new Date(datestring);
    return d.toLocaleDateString();
  },

  countMinutes: function(duration) {
    var minutes = duration * 60;
    return Math.round(minutes % 60);
  },

  countHours: function(duration) {
    var minutes = duration * 60;
    return Math.floor(minutes / 60);
  },

  // Email validator
  validEmail: function(email) {
    if (email === '') {
      return true;
    }
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
  }
};
