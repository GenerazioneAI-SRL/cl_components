import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/context_extensions.dart';
import 'genai_survey_answer_choice.dart';
import 'genai_survey_form_field.dart';
import 'models/genai_survey_question.dart';

/// Renders a single [GenaiSurveyQuestion] as a card with its answer choices
/// and inline validation, driven by a [GenaiSurveyFormField].
class GenaiSurveyQuestionCard extends StatelessWidget {
  final GenaiSurveyQuestion question;
  final void Function(List<Map<String, String>>) update;
  final FormFieldSetter<List<Map<String, String>>>? onSaved;
  final FormFieldValidator<List<Map<String, String>>>? validator;
  final AutovalidateMode? autovalidateMode;
  final String defaultErrorText;
  final bool isNumeric;

  const GenaiSurveyQuestionCard({
    super.key,
    required this.question,
    required this.update,
    required this.defaultErrorText,
    required this.isNumeric,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return GenaiSurveyFormField(
      defaultErrorText: defaultErrorText,
      question: question,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      builder: (state) {
        final c = context.colors;
        final ty = context.typography;
        final radius = context.radius;
        final spacing = context.spacing;
        final elevation = context.elevation;
        final hasAnswer = question.answers.isNotEmpty;
        final hasError = state.hasError;

        // Announce errors to assistive tech.
        return Semantics(
          container: true,
          label: question.question,
          hint: question.isMandatory ? 'Obbligatoria' : null,
          child: Container(
            margin: EdgeInsets.only(bottom: spacing.formFieldGap),
            decoration: BoxDecoration(
              color: c.surfaceCard,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(
                color: hasError
                    ? c.colorError
                    : hasAnswer
                        ? c.colorPrimary.withValues(alpha: 0.4)
                        : c.borderDefault,
                width: hasAnswer || hasError ? 1.5 : 1,
              ),
              boxShadow: elevation.shadow(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, c, ty, radius, spacing, hasAnswer),
                Padding(
                  padding: EdgeInsets.all(spacing.cardPadding),
                  child: GenaiSurveyAnswerChoice(
                    question: question,
                    isNumeric: isNumeric,
                    onChange: (value) {
                      state.didChange(value);
                      update(value);
                    },
                  ),
                ),
                if (hasError)
                  _buildError(
                      context, c, ty, radius, spacing, state.errorText!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, c, ty, radius, spacing, bool hasAnswer) {
    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color:
            hasAnswer ? c.colorPrimary.withValues(alpha: 0.05) : c.surfacePage,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius.md),
          topRight: Radius.circular(radius.md),
        ),
        border: Border(
          bottom: BorderSide(
            color: c.borderDefault.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.s2),
            decoration: BoxDecoration(
              color: hasAnswer
                  ? c.colorPrimary.withValues(alpha: 0.1)
                  : c.borderDefault.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Icon(
              hasAnswer
                  ? LucideIcons.circleCheck
                  : LucideIcons.circleQuestionMark,
              size: 20,
              color: hasAnswer ? c.colorPrimary : c.textSecondary,
            ),
          ),
          SizedBox(width: spacing.iconLabelGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: question.question,
                    style: ty.bodyMd.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    children: question.isMandatory
                        ? [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: c.colorError,
                                fontWeight: FontWeight.bold,
                              ),
                              semanticsLabel: ' obbligatoria',
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(height: spacing.s1),
                Text(
                  question.options.isNotEmpty
                      ? (question.singleChoice
                          ? "Seleziona un'opzione"
                          : 'Seleziona una o più opzioni')
                      : (question.isStarRating
                          ? 'Valuta da 1 a 5 stelle'
                          : 'Inserisci la tua risposta'),
                  style: ty.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, c, ty, radius, spacing, String error) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: spacing.cardPadding, vertical: spacing.s3),
        decoration: BoxDecoration(
          color: c.colorError.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius.md),
            bottomRight: Radius.circular(radius.md),
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.triangleAlert, size: 16, color: c.colorError),
            SizedBox(width: spacing.iconLabelGap),
            Expanded(
              child: Text(
                error,
                style: ty.caption.copyWith(color: c.colorError),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
