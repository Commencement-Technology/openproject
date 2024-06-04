#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Settings
  class WorkingDaysAndHoursParamsContract < ::ParamsContract
    include RequiresAdminGuard

    validate :working_days_are_present
    validate :hours_per_day_are_present
    validate :days_per_week_are_present
    validate :days_per_month_are_present
    validate :durations_are_positive_values
    validate :durations_are_within_bounds
    validate :days_per_week_and_days_per_month_are_consistent
    validate :unique_job

    protected

    def working_days_are_present
      if working_days.blank?
        errors.add :base, :working_days_are_missing
      end
    end

    def hours_per_day_are_present
      if hours_per_day.blank?
        errors.add :base, :hours_per_day_are_missing
      end
    end

    def days_per_week_are_present
      if days_per_week.blank?
        errors.add :base, :days_per_week_are_missing
      end
    end

    def days_per_month_are_present
      if days_per_month.blank?
        errors.add :base, :days_per_month_are_missing
      end
    end

    def durations_are_positive_values
      if hours_per_day &&
        days_per_week &&
        days_per_month &&
        any_duration_is_negative_or_zero?
        errors.add :base, :durations_are_not_positive_numbers
      end
    end

    def durations_are_within_bounds
      errors.add :base, :hours_per_day_is_out_of_bounds if hours_per_day.to_i > 24
      errors.add :base, :days_per_week_is_out_of_bounds if days_per_week.to_i > 7
      errors.add :base, :days_per_month_is_out_of_bounds if days_per_month.to_i > 31
    end

    def any_duration_is_negative_or_zero?
      !hours_per_day.to_i.positive? ||
        !days_per_week.to_i.positive? ||
        !days_per_month.to_i.positive?
    end

    def days_per_week_and_days_per_month_are_consistent
      if days_per_week &&
        days_per_month &&
        days_per_week.to_i != days_per_month.to_i / ChronicDuration::FULL_WEEKS_PER_MONTH
        errors.add :base, :days_per_week_and_days_per_month_are_inconsistent
      end
    end

    def unique_job
      WorkPackages::ApplyWorkingDaysChangeJob.new.check_concurrency do
        errors.add :base, :previous_working_day_changes_unprocessed
      end
    end

    def working_days
      params[:working_days]
    end

    def hours_per_day
      params[:hours_per_day]
    end

    def days_per_week
      params[:days_per_week]
    end

    def days_per_month
      params[:days_per_month]
    end
  end
end
